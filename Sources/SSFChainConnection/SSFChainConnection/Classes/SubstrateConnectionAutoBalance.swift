import Foundation
import SSFUtils
import SSFModels

public typealias SubstrateConnection = JSONRPCEngine

public final class SubstrateConnectionAutoBalance: ChainConnectionProtocol {
    public typealias T = SubstrateConnection

    public var isActive: Bool = true
    
    private let chainId: ChainModel.Id
    private let nodes: [URL]
    private let selectedNode: URL?
    private lazy var connectionFactory: ConnectionFactoryProtocol = {
        ConnectionFactory()
    }()
    
    private lazy var connectionIssuesCenter = NetworkIssuesCenterImpl.shared
    
    private weak var currentConnection: SubstrateConnection?
    private var failedUrls: Set<URL?> = []
    
    public init(
        nodes: [URL],
        selectedNode: URL? = nil,
        chainId: ChainModel.Id
    ) {
        self.nodes = nodes
        self.selectedNode = selectedNode
        self.chainId = chainId
    }
    
    // MARK: - Public methods
    
    public func connection() throws -> SubstrateConnection {
        guard let connection = currentConnection else {
            return try setupConnection(ignoredUrl: nil)
        }
        return connection
    }
    
    // MARK: - Private methods
    private func setupConnection(
        ignoredUrl: URL?
    ) throws -> SubstrateConnection {

        if ignoredUrl == nil,
           let connection = currentConnection,
           connection.url?.absoluteString == selectedNode?.absoluteString {
            return connection
        }

        let node = selectedNode ?? nodes.first(where: {
            ($0 != ignoredUrl) && !failedUrls.contains($0)
        })
        failedUrls.insert(ignoredUrl)

        guard let url = node else {
            throw ConnectionPoolError.onlyOneNode
        }


        if let connection = currentConnection {
            if connection.url == url {
                return connection
            } else if ignoredUrl != nil {
                connection.reconnect(url: url)
                return connection
            }
        }

        let connection = connectionFactory.createConnection(
            connectionName: nil,
            for: url,
            delegate: self
        )
        
        currentConnection = connection
        return connection
    }
}

// MARK: - WebSocketEngineDelegate
extension SubstrateConnectionAutoBalance: WebSocketEngineDelegate {
    public func webSocketDidChangeState(
        engine: WebSocketEngine,
        from oldState: WebSocketEngine.State,
        to newState: WebSocketEngine.State
    ) {
        guard selectedNode == nil,
              let previousUrl = engine.url
        else {
            return
        }
        
        switch newState {
        case let .waitingReconnection(attempt: attempt):
            isActive = true
            if attempt > NetworkConstants.websocketReconnectAttemptsLimit {
                _ = try? setupConnection(ignoredUrl: previousUrl)
            }
        case .notConnected:
            isActive = false
        default:
            isActive = true
        }
        
        connectionIssuesCenter.handle(chain: chainId, state: newState)
    }
}
