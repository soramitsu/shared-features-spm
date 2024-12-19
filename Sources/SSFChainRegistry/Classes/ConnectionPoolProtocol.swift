import Foundation
import SSFChainConnection
import SSFModels
import SSFUtils

public enum ConnectionPoolError: Error {
    case missingConnection
}

public protocol ConnectionPoolProtocol {
    func setupSubstrateConnection(for chain: ChainModel) throws -> SubstrateConnection
    func getSubstrateConnection(for chainId: ChainModel.Id) throws -> SubstrateConnection

    func setupWeb3EthereumConnection(for chain: ChainModel) throws -> Web3EthConnection
    func getWeb3EthereumConnection(for chainId: ChainModel.Id) throws -> Web3EthConnection
    
    func setupTonApiAssembly(url: URL, token: String, tonBridgeURL: URL) -> TonAPIAssembly
    func getTonApiAssembly() throws -> TonAPIAssembly
}

protocol ConnectionPoolDelegate: AnyObject {
    func webSocketDidChangeState(url: URL, state: WebSocketEngine.State)
}

public final class ConnectionPool: ConnectionPoolProtocol {
    private var autoBalancesByChainIds: [ChainModel.Id: any ChainConnectionProtocol] = [:]
    private let lock = ReaderWriterLock()
    private var tonApiAssembly: TonAPIAssembly?

    public init() {}

    // MARK: - Public methods

    public func setupSubstrateConnection(for chain: ChainModel) throws
        -> SubstrateConnection
    {
        if let connection = try? getSubstrateConnection(for: chain.chainId) {
            return connection
        }

        clearUnusedConnections()

        let nodes: [ChainNodeModel]
        if let selectedNode = chain.selectedNode {
            nodes = [selectedNode]
        } else {
            nodes = Array(chain.nodes)
        }
        let autoBalance = SubstrateConnectionAutoBalance(
            urls: nodes.map { $0.url },
            chainId: chain.chainId
        )

        lock.exclusivelyWrite { [weak self] in
            self?.autoBalancesByChainIds[chain.chainId] = autoBalance
        }

        return try autoBalance.connection()
    }

    public func getSubstrateConnection(
        for chainId: ChainModel.Id
    ) throws -> SubstrateConnection {
        guard let autoBalance = autoBalancesByChainIds[chainId] as? SubstrateConnectionAutoBalance else {
            throw ConnectionPoolError.missingConnection
        }
        return try autoBalance.connection()
    }

    public func setupWeb3EthereumConnection(for chain: ChainModel) throws
        -> Web3EthConnection
    {
        if let connection = try? getWeb3EthereumConnection(for: chain.chainId) {
            return connection
        }

        clearUnusedConnections()

        let autoBalance = Web3EthConnectionAutoBalance(chain: chain)

        lock.exclusivelyWrite { [weak self] in
            self?.autoBalancesByChainIds[chain.chainId] = autoBalance
        }

        return try autoBalance.connection()
    }

    public func getWeb3EthereumConnection(
        for chainId: ChainModel.Id
    ) throws -> Web3EthConnection {
        guard let autoBalance = lock
            .concurrentlyRead({ autoBalancesByChainIds[chainId] as? Web3EthConnectionAutoBalance
            }) else
        {
            throw ConnectionPoolError.missingConnection
        }

        return try autoBalance.connection()
    }
    
    public func setupTonApiAssembly(url: URL, token: String, tonBridgeURL: URL) -> TonAPIAssembly {
        if let tonApiAssembly {
            return tonApiAssembly
        }
        let assembly = TonAPIAssembly(tonAPIURL: url, token: token, tonBridgeURL: tonBridgeURL)
        tonApiAssembly = assembly
        return assembly
    }
    
    public func getTonApiAssembly() throws -> TonAPIAssembly {
        guard let tonApiAssembly else {
            throw ConnectionPoolError.missingConnection
        }
        return tonApiAssembly
    }

    // MARK: - Private methods

    private func clearUnusedConnections() {
        lock.exclusivelyWrite { [weak self] in
            self?.autoBalancesByChainIds = self?.autoBalancesByChainIds
                .filter { $0.value.isActive } ?? [:]
        }
    }
}
