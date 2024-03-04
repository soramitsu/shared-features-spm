import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFNetwork

final class EtherscanHistoryService: HistoryService {
    
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
    ) async throws -> EtherscanHistoryResponse {
        guard let baseURL = chainAsset.chain.externalApi?.history?.url else {
            throw HistoryError.urlMissing
        }
        
        let request = EtherscanHistoryRequest(
            baseURL: baseURL,
            chainAsset: chainAsset,
            address: address
        )
        
        let worker = NetworkWorker()
        let response: EtherscanHistoryResponse = try await worker.performRequest(with: request)
        return response
    }

    private func createMap(
        remote: EtherscanHistoryResponse,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionPageData {
        let asset = chainAsset.asset
        let transactions = remote.result?
            .filter { asset.ethereumType == .normal ? true : $0.contractAddress?.lowercased() == asset.id.lowercased() }
            .sorted(by: { $0.timestampInSeconds > $1.timestampInSeconds })
            .compactMap {
                AssetTransactionData.createTransaction(
                    from: $0,
                    address: address,
                    chainAsset: chainAsset
                )
            }.filter { ($0.amount?.decimalValue ?? 0) > 0 } ?? []
        
        return AssetTransactionPageData(transactions: transactions)
    }
}
