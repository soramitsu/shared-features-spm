import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFNetwork

final class GiantsquidHistoryService: HistoryService {
    
    private enum GiantsquidConfig {
        static let giantsquidRewardsEnabled = false
        static let giantsquidExtrinsicEnabled = false
    }

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
            !historyContext.isComplete, chainAsset.isUtility,
            let baseUrl = chainAsset.chain.externalApi?.history?.url
        else {
            return nil
        }
        
        async let remoteHistory = fetchHistory(
            address: address,
            url: baseUrl,
            filters: filters
        )
        
        var localHistory: [TransactionHistoryItem] = []
        if pagination.context == nil {
            localHistory = try await txStorage.fetchAll()
        }
        
        let merge = try await createSubqueryHistoryMerge(
            remoteHistory: remoteHistory,
            localHistory: localHistory,
            chainAsset: chainAsset,
            address: address
        )
        
        if pagination.context == nil {
            Task {
                await txStorage.remove(ids: merge.identifiersToRemove)
            }
        }
        
        return AssetTransactionPageData(
            transactions: merge.historyItems,
            context: nil
        )
    }

    // MARK: - Private methods

    private func fetchHistory(
        address: String,
        url: URL,
        filters: [WalletTransactionHistoryFilter]
    ) async throws -> GiantsquidResponseData {
        let queryString = prepareQueryForAddress(
            address,
            filters: filters
        )
        
        let request = try HistoryRequest(
            url: url,
            query: queryString
        )
        
        let response: GraphQLResponse<GiantsquidResponseData> = try await networkWorker.performRequest(with: request)
        return try response.result()
    }

    private func prepareFilter(
        filters: [WalletTransactionHistoryFilter],
        address: String
    ) -> String {
        var filterStrings: [String] = []

        if filters.contains(where: { $0.type == .other && $0.selected }), GiantsquidConfig.giantsquidExtrinsicEnabled {
            filterStrings.append(
                """
                          slashes(where: {accountId_containsInsensitive: \"\(address)\"}) {
                            accountId
                            amount
                            blockNumber
                            era
                            extrinsicHash
                            id
                            timestamp
                          }
                          bonds(where: {accountId_containsInsensitive: \"\(address)\"}) {
                            accountId
                            amount
                            blockNumber
                            extrinsicHash
                            id
                            success
                            timestamp
                            type
                          }
                """
            )
        }

        if filters.contains(where: { $0.type == .reward && $0.selected }), GiantsquidConfig.giantsquidRewardsEnabled {
            filterStrings.append(
                """
                rewards(where: {accountId_containsInsensitive: \"\(address)\"}) {
                accountId
                amount
                blockNumber
                era
                extrinsicHash
                id
                timestamp
                validator
                }
                """
            )
        }

        if filters.contains(where: { $0.type == .transfer && $0.selected }) {
            filterStrings.append(
                """
                          transfers(where: {account: {id_eq: "\(address)"}}, orderBy: id_DESC) {
                           id
                               transfer {
                                 amount
                                 blockNumber
                                 extrinsicHash
                                 from {
                                   id
                                 }
                                 to {
                                   id
                                 }
                                 timestamp
                                 success
                                 id
                               }
                               direction
                          }
                """
            )
        }

        return filterStrings.joined(separator: "\n")
    }

    private func prepareQueryForAddress(
        _ address: String,
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        let filterString = prepareFilter(filters: filters, address: address)
        return """
        query MyQuery {
          \(filterString)
        }
        """
    }

    private func createSubqueryHistoryMerge(
        remoteHistory: GiantsquidResponseData,
        localHistory: [TransactionHistoryItem],
        chainAsset: ChainAsset,
        address: String
    ) -> TransactionHistoryMergeResult {
        if localHistory.isEmpty {
            let transactions: [AssetTransactionData] = remoteHistory.history.map { item in
                item.createTransactionForAddress(
                    address,
                    chainAsset: chainAsset
                )
            }
            
            return TransactionHistoryMergeResult(
                historyItems: transactions,
                identifiersToRemove: []
            )
        } else {
            let manager = TransactionHistoryMergeManager(
                address: address,
                chainAsset: chainAsset
            )
            return manager.merge(
                subscanItems: remoteHistory.history,
                localItems: localHistory
            )
        }
    }
}
