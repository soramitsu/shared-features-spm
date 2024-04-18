import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFNetwork

final class SubsquidHistoryService: HistoryService {
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
        
        let filteredTransactions = remoteHistory.historyElements.sorted { element1, element2 in
            element2.timestampInSeconds < element1.timestampInSeconds
        }
        
        let transactions: [AssetTransactionData] = filteredTransactions.map { item in
            item.createTransactionForAddress(
                address,
                chainAsset: chainAsset
            )
        }
        
        let map = createSubqueryHistoryMap(
            transactions: transactions,
            pagination: pagination
        )
        return map
    }
    
    // MARK: - Private methods

    private func fetchHistory(
        address: String,
        count: Int,
        cursor: String?,
        url: URL,
        filters: [WalletTransactionHistoryFilter]
    ) async throws -> SubsquidHistoryResponse {
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
        
        let response: GraphQLResponse<SubsquidHistoryResponse> = try await networkWorker.performRequest(with: request)
        return try response.result()
    }

    private func prepareFilter(
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        var filterStrings: [String] = []

        if !filters.contains(where: { $0.type == .other && $0.selected }) {
            filterStrings.append("extrinsic_isNull: true")
        }

        if !filters.contains(where: { $0.type == .reward && $0.selected }) {
            filterStrings.append("reward_isNull: true")
        }

        if !filters.contains(where: { $0.type == .transfer && $0.selected }) {
            filterStrings.append("transfer_isNull: true")
        }

        return filterStrings.joined(separator: ",")
    }

    private func prepareQueryForAddress(
        _ address: String,
        count: Int,
        cursor: String?,
        filters: [WalletTransactionHistoryFilter]
    ) -> String {
        let filterString = prepareFilter(filters: filters)
        let offset: Int = cursor.map { Int($0) ?? 0 } ?? 0
        return """
        query MyQuery {
          historyElements(where: {address_eq: "\(address)", \(filterString)}, orderBy: timestamp_DESC, limit: \(count), offset: \(offset)) {
            timestamp
            id
            extrinsicIdx
            extrinsicHash
            blockNumber
            address
                                    extrinsic {
                                      call
                                      fee
                                      hash
                                      module
                                      success
                                    }
                    transfer {
                    amount
                    eventIdx
                    fee
                    from
                    success
                    to
                    }
                                reward {
                                  amount
                                  era
                                  eventIdx
                                  isReward
                                  stash
                                  validator
                                }
          }
        }
        """
    }

    private func createSubqueryHistoryMap(
        transactions: [AssetTransactionData],
        pagination: Pagination
    ) -> AssetTransactionPageData? {
        let context = pagination.context
        let endCursor = context.map { (Int($0["endCursor"] ?? "0") ?? 0) + pagination.count } ?? pagination.count
        return AssetTransactionPageData(
            transactions: transactions,
            context: ["endCursor": "\(endCursor)"]
        )
    }
}
