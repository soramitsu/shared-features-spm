import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFNetwork

final actor AlchemyHistoryService: HistoryService {
    
    private let networkWorker: NetworkWorker
    
    init(networkWorker: NetworkWorker) {
        self.networkWorker = networkWorker
    }
    
    // MARK: - HistoryService
    
    func fetchTransactionHistory(
        chainAsset: ChainAsset,
        address: String,
        filters: [WalletTransactionHistoryFilter],
        pagination: Pagination
    ) async throws -> AssetTransactionPageData? {
        guard let historyUrl = chainAsset.chain.externalApi?.history?.url else {
            throw HistoryError.urlMissing
        }
        let apiKey = chainAsset.chain.externalApi?.history?.apiKey
        let baseURL = createBaseUrl(baseUrl: historyUrl, with: apiKey)
        async let received = fetchReceivedHistory(
            baseURL: baseURL,
            address: address
        )
        async let sent = fetchSentHistory(
            baseURL: baseURL,
            address: address
        )

        let map = try await createMap(
            received: received,
            sent: sent,
            address: address,
            chainAsset: chainAsset
        )
        return map
    }
    
    // MARK: - Private methods
    
    private func createBaseUrl(baseUrl: URL, with apiKey: String?) -> URL {
        guard let apiKey else {
            return baseUrl
        }
        return baseUrl.appendingPathComponent(apiKey)
    }

    private func fetchReceivedHistory(
        baseURL: URL,
        address: String
    ) async throws -> AlchemyHistory {
        let receivedRequest = AlchemyHistoryRequest(
            toAddress: address,
            category: [.erc20, .external, .internal, .erc1155, .erc721, .specialnft]
        )
        let history = try await perform(
            request: receivedRequest,
            baseURL: baseURL
        )
        return history
    }

    private func fetchSentHistory(
        baseURL: URL,
        address: String
    ) async throws -> AlchemyHistory {
        let receivedRequest = AlchemyHistoryRequest(
            fromAddress: address,
            category: [.erc20, .external, .internal, .erc1155, .erc721, .specialnft]
        )
        let history = try await perform(
            request: receivedRequest,
            baseURL: baseURL
        )
        return history
    }
    
    private func perform(
        request: AlchemyHistoryRequest,
        baseURL: URL
    ) async throws -> AlchemyHistory {
        let body = JSONRPCInfo(
            identifier: 1,
            jsonrpc: "2.0",
            method: AlchemyEndpoint.getAssetTransfers.rawValue,
            params: [request]
        )
        let paramsEncoded = try JSONEncoder().encode(body)
        let request = AlchemyRequest(
            baseURL: baseURL,
            body: paramsEncoded
        )
        let response: AlchemyResponse<AlchemyHistory> = try await networkWorker.performRequest(with: request)
        return response.result
    }

    private func createMap(
        received: AlchemyHistory,
        sent: AlchemyHistory,
        address: String,
        chainAsset: ChainAsset
    ) throws -> AssetTransactionPageData? {
        let history = received.transfers + sent.transfers
        
        let transactions = history
            .filter { $0.asset?.lowercased() == chainAsset.asset.symbol.lowercased() }
            .sorted(by: { $0.timestampInSeconds > $1.timestampInSeconds })
            .compactMap {
                AssetTransactionData.createTransaction(
                    from: $0,
                    address: address
                )
            }
        
        return AssetTransactionPageData(transactions: transactions)
    }
}
