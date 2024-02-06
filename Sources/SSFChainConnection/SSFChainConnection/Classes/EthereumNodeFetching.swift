import Foundation
import Web3
import SSFModels

protocol EthereumNodeFetching {
    func getNode(for chain: ChainModel) throws -> Web3.Eth
    func getHttps(for chain: ChainModel) throws -> Web3.Eth
}

final class EthereumNodeFetchingDefault: EthereumNodeFetching {
    func getNode(for chain: ChainModel) throws -> Web3.Eth {
        let randomWssNode = chain.nodes.filter { $0.url.absoluteString.contains("wss") }.randomElement()
        let hasSelectedWssNode = chain.selectedNode?.url.absoluteString.contains("wss") == true
        let node = hasSelectedWssNode ? chain.selectedNode : randomWssNode

        guard let wssURL = node?.url, let apiKey = node?.apikey?.key else {
            return try getHttps(for: chain)
        }

        let finalURL = wssURL.appendingPathComponent(apiKey)

        return try Web3(wsUrl: finalURL.absoluteString).eth
    }

    func getHttps(for chain: ChainModel) throws -> Web3.Eth {
        let randomWssNode = chain.nodes.filter { $0.url.absoluteString.contains("https") }.randomElement()
        let hasSelectedWssNode = chain.selectedNode?.url.absoluteString.contains("https") == true
        let node = hasSelectedWssNode ? chain.selectedNode : randomWssNode

        guard let httpsURL = node?.url else {
            throw ConnectionPoolError.connectionFetchingError
        }

        return Web3(rpcURL: httpsURL.absoluteString).eth
    }
}
