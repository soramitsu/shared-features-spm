import Foundation
import SSFModels
import SSFUtils

public typealias SubstrateConnection = JSONRPCEngine

public final class SubstrateConnectionAutoBalance: ChainConnectionProtocol {
    public typealias T = SubstrateConnection

    public var isActive: Bool = true

    private let chainId: ChainModel.Id
    private let urls: [URL]
    private lazy var connectionFactory: ConnectionFactoryProtocol = ConnectionFactory()

    private lazy var connectionIssuesCenter = NetworkIssuesCenterImpl.shared

    private weak var currentConnection: SubstrateConnection?
    private var failedUrls: Set<URL?> = []

    public init(
        urls: [URL],
        chainId: ChainModel.Id
    ) {
        self.urls = urls
        self.chainId = chainId
    }

    // MARK: - Public methods

    public func connection() throws -> SubstrateConnection {
        guard let connection = currentConnection else {
            return try setupConnection()
        }
        return connection
    }

    // MARK: - Private methods

    private func setupConnection() throws -> SubstrateConnection {
        let connection = try connectionFactory.createConnection(
            connectionName: chainId,
            for: urls,
            delegate: self
        )
        currentConnection = connection
        return connection
    }
}

// MARK: - WebSocketEngineDelegate

extension SubstrateConnectionAutoBalance: WebSocketEngineDelegate {
    public func webSocketDidChangeState(
        engine _: WebSocketEngine,
        to newState: WebSocketEngine.State
    ) {
        switch newState {
        case .waitingNewLoop:
            isActive = true
        case .notConnected:
            isActive = false
        default:
            isActive = true
        }

        connectionIssuesCenter.handle(chain: chainId, state: newState)
    }
}
