import Foundation
import SSFModels
import Web3
import SSFUtils

public final class EthereumConnectionPool: ConnectionPoolProtocol {
    public typealias T = Web3.Eth

    private(set) var connectionsByChainIds: [ChainModel.Id: Web3.Eth] = [:]
    private weak var delegate: ConnectionPoolDelegate?

    private lazy var lock = NSLock()
    
    public init() {}

    public func setupConnection(for chain: SSFModels.ChainModel) throws -> Web3.Eth {
        if let connection = connectionsByChainIds[chain.chainId] {
            return connection
        }

        lock.lock()
        defer {
            lock.unlock()
        }

        let ws = try EthereumNodeFetching().getNode(for: chain)
        connectionsByChainIds[chain.chainId] = ws

        return ws
    }

    public func getConnection(for chainId: ChainModel.Id) -> Web3.Eth? {
        lock.lock()
        defer {
            lock.unlock()
        }

        return connectionsByChainIds[chainId]
    }

    public func setDelegate(_ delegate: ConnectionPoolDelegate) {
        self.delegate = delegate
    }

    public func resetConnection(for chainId: ChainModel.Id) {
        connectionsByChainIds = connectionsByChainIds.filter { $0.key != chainId }
    }
}
