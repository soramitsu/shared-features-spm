import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFChainRegistry
import SSFRuntimeCodingService
import SSFNetwork

class SoraSubsquidHistoryService: HistoryService {
    private let txStorage: AsyncAnyRepository<TransactionHistoryItem>
    private let runtimeService: RuntimeProviderProtocol
    private let networkWorker: NetworkWorker

    init(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        runtimeService: RuntimeProviderProtocol,
        networkWorker: NetworkWorker
    ) {
        self.txStorage = txStorage
        self.runtimeService = runtimeService
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
            let baseUrl = chainAsset.chain.externalApi?.history?.url
        else {
            return nil
        }

        async let remoteHistory = fetchHistory(
                address: address,
                count: pagination.count,
                cursor: pagination.context?["endCursor"],
                url: baseUrl,
                filters: filters
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

        return try await AssetTransactionPageData(
            transactions: merge.historyItems,
            context: remoteHistory.historyElementsConnection.pageInfo?.toPaginationContext()
        )
    }

    private func fetchHistory(
        address: String,
        count: Int,
        cursor: String?,
        url: URL,
        filters: [WalletTransactionHistoryFilter]
    ) async throws -> SoraSubsquidHistoryConnectionResponse {
        let queryString = prepareQueryForAddress(
            address,
            count: count,
            cursor: cursor,
            filters: filters
        )
        
        let request = try HistoryRequest(
            url: url,
            query: queryString
        )
        
        let response: GraphQLResponse<SoraSubsquidHistoryConnectionResponse> = try await networkWorker.performRequest(with: request)
        return try response.result()
    }

    private func prepareFilter(
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        var filterStrings: [String] = []

        if !filters.contains(where: { $0.type == .swap && $0.selected }) {
            filterStrings.append("\"swap\"")
        }

        if !filters.contains(where: { $0.type == .reward && $0.selected }) {
            filterStrings.append("\"rewarded\"")
        }

        if !filters.contains(where: { $0.type == .transfer && $0.selected }) {
            filterStrings.append("\"transfer\"")
        }

        guard !filterStrings.isEmpty else {
            return ""
        }

        let resultFilters = filterStrings.joined(separator: ",")
        return ", method_not_in: [\(resultFilters)]"
    }

    private func prepareQueryForAddress(
        _ address: String,
        count: Int,
        cursor: String?,
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        let after: String = cursor.map { "\($0)" } ?? "1"
        let filter = prepareFilter(filters: filters)

        return """
        query MyQuery {
                  historyElementsConnection(
                    where: {
                      OR: [
                        { address_eq: "\(address)"\(filter) },
                        { dataTo_eq: "\(address)"\(filter) },
                      ]
                    },
                    after: "\(after)"
                    first: \(count),
                    orderBy: timestamp_DESC,
                  ) {
                    pageInfo {
                      endCursor
                      hasNextPage
                      hasPreviousPage
                      startCursor
                    }
                    totalCount
                    edges {
                      node {
                        address
                        blockHash
                        blockHeight
                        callNames
                        data
                        dataFrom
                        dataTo
                        id
                        method
                        module
                        name
                        networkFee
                        timestamp
                        type
                        updatedAtBlock
                        execution {
                          success
                        }
                      }
                    }
                  }
                }
        """
    }

    private func createSubqueryHistoryMerge(
        remote: SoraSubsquidHistoryConnectionResponse,
        local: [TransactionHistoryItem],
        chainAsset: ChainAsset,
        address: String
    ) -> TransactionHistoryMergeResult {
        let remoteTransactions = remote.historyElementsConnection.edges.map { $0.node }
        let filteredTransactions = remoteTransactions
            .filter { transaction in
                if chainAsset.asset.symbol.lowercased() == "val", transaction.method == "rewarded" {
                    return true
                }
                
                if chainAsset.asset.isUtility, transaction.module == "staking", transaction.method != "rewarded" {
                    return true
                }
                
                if let targetAssetId = transaction.data?.targetAssetId, targetAssetId == chainAsset.asset.currencyId {
                    return true
                }
                
                if let baseAssetId = transaction.data?.baseAssetId, baseAssetId == chainAsset.asset.currencyId {
                    return true
                }
                
                if let assetId = transaction.data?.assetId, assetId == chainAsset.asset.currencyId {
                    return true
                }
                
                return false
            }
        
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
            let transactions: [AssetTransactionData] = filteredTransactions.map { item in
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
}
