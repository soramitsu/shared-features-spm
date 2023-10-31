import Foundation
import SSFUtils
import SSFModels

public typealias ChainConnection = JSONRPCEngine

public protocol ChainConnectionProtocol {
    var isActive: Bool { get }
    func connection() throws -> ChainConnection
}

public final class ChainConnectionAutoBalance: ChainConnectionProtocol {

    public var isActive: Bool = true
    
    private let nodes: [URL]
    private let selectedNode: URL?
    private lazy var connectionFactory: ConnectionFactoryProtocol = {
        ConnectionFactory()
    }()
    
    private weak var currentConnection: ChainConnection?
    private var failedUrls: Set<URL?> = []
    
    public init(nodes: [URL], selectedNode: URL? = nil) {
        self.nodes = nodes
        self.selectedNode = selectedNode
    }
    
    // MARK: - Public methods
    
    public func connection() throws -> ChainConnection {
        guard let connection = currentConnection else {
            return try setupConnection(ignoredUrl: nil)
        }
        return connection
    }
    
    // MARK: - Private methods
    private func setupConnection(ignoredUrl: URL?) throws -> ChainConnection {

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
extension ChainConnectionAutoBalance: WebSocketEngineDelegate {
    public func webSocketDidChangeState(
        engine: SSFUtils.WebSocketEngine,
        from oldState: SSFUtils.WebSocketEngine.State,
        to newState: SSFUtils.WebSocketEngine.State
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
    }
}
