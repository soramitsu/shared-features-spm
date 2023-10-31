import Foundation
import SSFUtils
import SSFChainConnection
import SSFModels

public enum ConnectionPoolError: Error {
    case missingConnection
}

public protocol ConnectionPoolProtocol {
    func setupConnection(for chain: ChainModel) throws -> ChainConnection
    func getConnection(for chainId: ChainModel.Id) throws -> ChainConnection
}

protocol ConnectionPoolDelegate: AnyObject {
    func webSocketDidChangeState(url: URL, state: WebSocketEngine.State)
}

public final class ConnectionPool: ConnectionPoolProtocol {
    private let mutex = NSLock()
    private var autoBalancesByChainIds: [ChainModel.Id: ChainConnectionProtocol] = [:]
    
    public init() {}

    public func setupConnection(for chain: ChainModel) throws -> ChainConnection {
        mutex.lock()

        defer {
            mutex.unlock()
        }
        
        if let connection = try? getConnection(for: chain.chainId) {
            return connection
        }

        clearUnusedConnections()

        let nodes = chain.nodes.map { $0.url }
        let autoBalance = ChainConnectionAutoBalance(
            nodes: nodes,
            selectedNode: chain.selectedNode?.url
        )

        autoBalancesByChainIds[chain.chainId] = autoBalance

        return try autoBalance.connection()
    }

    public func getConnection(for chainId: ChainModel.Id) throws -> ChainConnection {
        guard let autoBalance = autoBalancesByChainIds[chainId] else {
            throw ConnectionPoolError.missingConnection
        }
        return try autoBalance.connection()
    }
    
    private func clearUnusedConnections() {
        autoBalancesByChainIds = autoBalancesByChainIds.filter { $0.value.isActive }
    }
}
