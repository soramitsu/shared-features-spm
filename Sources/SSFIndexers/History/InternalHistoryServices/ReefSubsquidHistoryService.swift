import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFNetwork

final class ReefSubsquidHistoryService: HistoryService {
    private let txStorage: AsyncAnyRepository<TransactionHistoryItem>
    private let networkWorker: NetworkWorker

    init(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) {
        self.txStorage = txStorage
        self.networkWorker = networkWorker
    }
    
    // MARK: - HistoryService
    
    func fetchTransactionHistory(
        chainAsset: ChainAsset,
        address: String,
        filters: [WalletTransactionHistoryFilter],
        pagination: Pagination
    ) async throws -> AssetTransactionPageData? {
        let historyContext = TransactionHistoryContext(
            context: pagination.context ?? [:],
            defaultRow: pagination.count
        ).byApplying(filters: filters)

        guard
            !historyContext.isComplete,
            chainAsset.isUtility,
            let baseUrl = chainAsset.chain.externalApi?.history?.url
        else {
            return nil
        }
        
        async let remoteHistory = try await fetchHistory(
            address: address,
            url: baseUrl,
            filters: filters,
            count: 20,
            transfersCursor: pagination.context?["transfersCursor"],
            stakingsCursor: pagination.context?["stakingsCursor"]
        )

        var localHistory: [TransactionHistoryItem] = []
        if pagination.context == nil {
            localHistory = try await txStorage.fetchAll()
        }

        let merge = try await createSubqueryHistoryMerge(
            remote: remoteHistory,
            local: localHistory,
            chainAsset: chainAsset,
            address: address
        )

        if pagination.context == nil {
            Task {
                await txStorage.remove(ids: merge.identifiersToRemove)
            }
        }

        let map = try await createHistoryMap(
            merge: merge,
            remote: remoteHistory
        )
        return map
    }
    
    // MARK: - Private methods

    private func fetchHistory(
        address: String,
        url: URL,
        filters: [WalletTransactionHistoryFilter],
        count: Int,
        transfersCursor: String?,
        stakingsCursor: String?
    ) async throws -> ReefResponseData {
        let queryString = prepareQueryForAddress(
            address,
            filters: filters,
            count: count,
            transfersCursor: transfersCursor,
            stakingsCursor: stakingsCursor
        )

        let request = try HistoryRequest(
            url: url,
            query: queryString
        )
        
        let response: GraphQLResponse<ReefResponseData> = try await networkWorker.performRequest(with: request)
        return try response.result()
    }

    private func prepareFilter(
        filters: [WalletTransactionHistoryFilter],
        address: String,
        count: Int,
        transfersCursor: String?,
        stakingsCursor: String?
    ) -> String {
        var filterStrings: [String] = []
        let transfersAfter = transfersCursor.map { "after: \"\($0)\"" } ?? ""
        let stakingsAfter = stakingsCursor.map { "after: \"\($0)\"" } ?? ""

        if filters.contains(where: { $0.type == .transfer && $0.selected }) {
            filterStrings.append(
                """
                transfersConnection(\(transfersAfter),
                 first: \(count), where: {AND: [{type_eq: Native}, {OR: [{from: {id_eq: "\(address)"}}, {to: {id_eq: "\(address)"}}]}]}, orderBy: timestamp_DESC) {
                    edges {
                          node {
                            amount
                            timestamp
                            success
                    extrinsicHash
                            to {
                              id
                            }
                            from {
                              id
                            }
                signedData
                          }
                        }
                        pageInfo {
                endCursor
                          hasNextPage
                        }
                  }
                """
            )
        }

        if filters.contains(where: { $0.type == .reward && $0.selected }) {
            filterStrings.append("""
                        stakingsConnection(\(stakingsAfter),
                 first: \(count), orderBy: timestamp_DESC, where: {AND: {signer: {id_eq: "\(address)"}, amount_gt: "0", type_eq: Reward}}) {
                                edges {
                                                                  node {
            id
                                                                    amount
                                                                    timestamp
                                                                  }
                                                                }
                                                                pageInfo {
            endCursor
                                                                  hasNextPage
                                                                }
                            }
            """)
        }

        return filterStrings.joined(separator: "\n")
    }

    private func prepareQueryForAddress(
        _ address: String,
        filters: [WalletTransactionHistoryFilter],
        count: Int,
        transfersCursor: String?,
        stakingsCursor: String?
    ) -> String {
        let filterString = prepareFilter(
            filters: filters,
            address: address,
            count: count,
            transfersCursor: transfersCursor,
            stakingsCursor: stakingsCursor
        )
        return """
        query MyQuery {
          \(filterString)
        }
        """
    }

    private func createSubqueryHistoryMerge(
        remote: ReefResponseData,
        local: [TransactionHistoryItem],
        chainAsset: ChainAsset,
        address: String
    ) -> TransactionHistoryMergeResult {
        let remoteTransactions: [WalletRemoteHistoryItemProtocol] = remote.history
        
        if !local.isEmpty {
            let manager = TransactionHistoryMergeManager(
                address: address,
                chainAsset: chainAsset
            )
            return manager.merge(
                subscanItems: remoteTransactions,
                localItems: local
            )
        } else {
            let transactions: [AssetTransactionData] = remoteTransactions.sorted(by: { item1, item2 in
                item1.itemTimestamp > item2.itemTimestamp
            }).map { item in
                item.createTransactionForAddress(
                    address,
                    chainAsset: chainAsset
                )
            }
            
            return TransactionHistoryMergeResult(
                historyItems: transactions,
                identifiersToRemove: []
            )
        }
    }

    private func createHistoryMap(
        merge: TransactionHistoryMergeResult,
        remote: ReefResponseData
    ) -> AssetTransactionPageData? {
            var context: [String: String] = [:]
            if let transfersCursor = remote.transfersConnection?.pageInfo?.endCursor {
                context["transfersCursor"] = transfersCursor
            }

            if let stakingsCursor = remote.stakingsConnection?.pageInfo?.endCursor {
                context["stakingsCursor"] = stakingsCursor
            }

            let hasNextPage = (remote.transfersConnection?.pageInfo?.hasNextPage).or(false) || (remote.stakingsConnection?.pageInfo?.hasNextPage).or(false)

            return AssetTransactionPageData(
                transactions: merge.historyItems,
                context: hasNextPage ? context : nil
            )
    }
}
