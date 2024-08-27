import Foundation
import SSFChainConnection
import SSFModels
import SSFUtils

public typealias ChainConnection = JSONRPCEngine

public protocol ConnectionPoolProtocol {
    associatedtype T

    func setupConnection(for chain: ChainModel) async throws -> T
    func getConnection(for chainId: ChainModel.Id) async -> T?
    func setDelegate(_ delegate: ConnectionPoolDelegate) async
    func resetConnection(for chainId: ChainModel.Id) async
}

public protocol ConnectionPoolDelegate: AnyObject {
    func webSocketDidChangeState(chainId: ChainModel.Id, state: WebSocketEngine.State)
}

public actor ConnectionPool {
    struct ConnectionWrapper {
        let chainId: String
        let connection: WeakWrapper
    }

    private let connectionFactory: ConnectionFactoryProtocol
    private lazy var injector = NodeApiKeyInjector()
    private weak var delegate: ConnectionPoolDelegate?

    private(set) var connections: [ConnectionWrapper] = []

    public init(connectionFactory: ConnectionFactoryProtocol) {
        self.connectionFactory = connectionFactory
    }

    private func clearUnusedConnections() {
        let filtred = connections.filter { $0.connection.target != nil }
        connections = filtred
    }
}

// MARK: - ConnectionPoolProtocol

extension ConnectionPool: ConnectionPoolProtocol {
    public typealias T = ChainConnection

    public func setupConnection(for chain: ChainModel) async throws -> ChainConnection {
        if let connection = await getConnection(for: chain.chainId) {
            return connection
        }
        let nodesForPreparing: [ChainNodeModel]
        if let selectedNode = chain.selectedNode {
            nodesForPreparing = [selectedNode]
        } else {
            nodesForPreparing = Array(chain.nodes)
        }

        let preparedUrls = injector.injectKey(nodes: nodesForPreparing)
        let connection = try connectionFactory.createConnection(
            connectionName: chain.chainId,
            for: preparedUrls,
            delegate: self
        )

        let wrapper = ConnectionWrapper(chainId: chain.chainId, connection: WeakWrapper(target: connection))
        connections.append(wrapper)
        return connection
    }

    public func getConnection(for chainId: ChainModel.Id) async -> ChainConnection? {
        connections.first(where: { $0.chainId == chainId })?.connection.target as? ChainConnection
    }

    public func setDelegate(_ delegate: any ConnectionPoolDelegate) async {
        self.delegate = delegate
    }

    public func resetConnection(for chainId: ChainModel.Id) async {
        if let connection = await getConnection(for: chainId) {
            connection.disconnectIfNeeded()
        }
        connections = connections.filter { $0.chainId == chainId }
    }
}

// MARK: - WebSocketEngineDelegate

extension ConnectionPool: WebSocketEngineDelegate {
    public func webSocketDidChangeState(
        engine: WebSocketEngine,
        to newState: WebSocketEngine.State
    ) {
        guard let chainId = engine.connectionName else {
            return
        }

        delegate?.webSocketDidChangeState(chainId: chainId, state: newState)
    }
}
