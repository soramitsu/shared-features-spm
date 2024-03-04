import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFChainRegistry
import SSFRuntimeCodingService
import SSFNetwork

final class SubqueryHistoryService: HistoryService {
    private let txStorage: AsyncAnyRepository<TransactionHistoryItem>
    private let runtimeService: RuntimeProviderProtocol

    init(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        runtimeService: RuntimeProviderProtocol
    ) {
        self.txStorage = txStorage
        self.runtimeService = runtimeService
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

        async let remoteHistory = fetchSubqueryHistoryData(
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

        let mergeResult = try await merge(
            remote: remoteHistory,
            local: localHistory,
            runtime: runtimeService.fetchCoderFactory(),
            chainAsset: chainAsset,
            address: address
        )

        if pagination.context == nil {
            Task {
                await txStorage.remove(ids: mergeResult.identifiersToRemove)
            }
        }

        let result = await AssetTransactionPageData(
            transactions: mergeResult.historyItems,
            context: try remoteHistory.historyElements.pageInfo.toContext()
        )
        return result
    }
    
    
    // MARK: - Privamte methods

    private func fetchSubqueryHistoryData(
        address: String,
        count: Int,
        cursor: String?,
        url: URL,
        filters: [WalletTransactionHistoryFilter]
    ) async throws -> SubqueryHistoryData {
        let queryString = prepareQueryForAddress(
            address,
            count: count,
            cursor: cursor,
            filters: filters
        )
        
        let worker = NetworkWorker()
        let request = try HistoryRequest(
            url: url,
            query: queryString
        )
        
        let response: GraphQLResponse<SubqueryHistoryData> = try await worker.performRequest(with: request)
        return try response.result()
    }

    private func prepareFilter(
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        var filterStrings: [String] = []

        if !filters.contains(where: { $0.type == .other && $0.selected }) {
            filterStrings.append("{extrinsic: { isNull: true }}")
        }

        if !filters.contains(where: { $0.type == .reward && $0.selected }) {
            filterStrings.append("{reward: { isNull: true }}")
        }

        if !filters.contains(where: { $0.type == .transfer && $0.selected }) {
            filterStrings.append("{transfer: { isNull: true }}")
        }

        return filterStrings.joined(separator: ",")
    }

    private func prepareQueryForAddress(
        _ address: String,
        count: Int,
        cursor: String?,
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        let after = cursor.map { "\"\($0)\"" } ?? "null"
        let filterString = prepareFilter(filters: filters)
        return """
        {
            historyElements(
                 after: \(after),
                 first: \(count),
                 orderBy: TIMESTAMP_DESC,
                 filter: {
                     address: { equalTo: \"\(address)\"},
                     and: [
                        \(filterString)
                     ]
                 }
             ) {
                 pageInfo {
                     startCursor,
                     endCursor
                 },
                 nodes {
                     id
                     timestamp
                     address
                     reward
                     extrinsic
                     transfer
                 }
             }
        }
        """
    }

    private func merge(
        remote: SubqueryHistoryData,
        local: [TransactionHistoryItem],
        runtime: RuntimeCoderFactoryProtocol,
        chainAsset: ChainAsset,
        address: String
    ) throws -> TransactionHistoryMergeResult {
        let remoteTransactions = remote.historyElements.nodes
        let filteredTransactions = try remoteTransactions.filter { transaction in
            var assetId: String?
            
            if let transfer = transaction.transfer {
                assetId = transfer.assetId
            } else if let reward = transaction.reward {
                assetId = reward.assetId
            } else if let extrinsic = transaction.extrinsic {
                assetId = extrinsic.assetId
            }
            
            if chainAsset.chainAssetType != .normal, assetId == nil {
                return false
            }
            
            if chainAsset.chainAssetType == .normal, assetId != nil {
                return false
            }
            
            if chainAsset.chainAssetType == .normal, assetId == nil {
                return true
            }
            
            guard let assetId = assetId else {
                return false
            }
            
            let assetIdBytes = try Data(hexStringSSF: assetId)
            let encoder = runtime.createEncoder()
            guard let currencyId = chainAsset.currencyId else {
                return false
            }
            
            guard let type = runtime.metadata.schema?.types
                .first(where: { $0.type.path.contains("CurrencyId") })?
                .type
                .path
                .joined(separator: "::")
            else {
                return false
            }
            try encoder.append(currencyId, ofType: type)
            let currencyIdBytes = try encoder.encode()
            
            return currencyIdBytes == assetIdBytes
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
