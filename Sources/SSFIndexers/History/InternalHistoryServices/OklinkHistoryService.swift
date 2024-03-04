import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFNetwork

final class OklinkHistoryService: HistoryService {
    
    // MARK: - HistoryService

    func fetchTransactionHistory(
        chainAsset: ChainAsset,
        address: String,
        filters: [WalletTransactionHistoryFilter],
        pagination: Pagination
    ) async throws -> AssetTransactionPageData? {
        let remote = try await fetchHistory(
            address: address,
            chainAsset: chainAsset
        )
        
        let map = createMap(
            remote: remote,
            address: address,
            chainAsset: chainAsset
        )
        return map
    }
    
    // MARK: - Private methods
    
    private func fetchHistory(
        address: String,
        chainAsset: ChainAsset
    ) async throws -> OklinkHistoryResponse {
        guard let historyUrl = chainAsset.chain.externalApi?.history?.url else {
            throw HistoryError.urlMissing
        }

        let request = OklinkHistoryRequest(
            baseUrl: historyUrl,
            chainAsset: chainAsset
        )

        let worker = NetworkWorker()
        let response: OklinkHistoryResponse = try await worker.performRequest(with: request)
        return response
    }

    private func createMap(
        remote: OklinkHistoryResponse,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionPageData? {
        let asset = chainAsset.asset
        let remoteTransactions = remote.data.first?.transactionLists
        let isNormalAsset = asset.ethereumType == .normal

        let transactions = remoteTransactions?
            .filter { isNormalAsset ? true : $0.tokenContractAddress.lowercased() == asset.id.lowercased() }
            .sorted(by: { $0.transactionTime > $1.transactionTime })
            .compactMap {
                AssetTransactionData.createTransaction(
                    from: $0,
                    address: address,
                    chainAsset: chainAsset
                )
            }.filter { ($0.amount?.decimalValue ?? 0) > 0 }
        guard let transactions else {
            return nil
        }
        
        return AssetTransactionPageData(transactions: transactions)
    }
}
