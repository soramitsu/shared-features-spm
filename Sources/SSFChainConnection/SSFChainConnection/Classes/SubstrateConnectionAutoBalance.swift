import Foundation
import SSFModels
import SSFUtils

public typealias SubstrateConnection = JSONRPCEngine

public actor SubstrateConnectionAutoBalance: ChainConnectionProtocol {
    public typealias T = SubstrateConnection

    private var isActive: Bool = true

    private let chainId: ChainModel.Id
    private let urls: [URL]
    private let selecteUrl: URL?
    private lazy var connectionFactory: ConnectionFactoryProtocol = ConnectionFactory()

    private lazy var connectionIssuesCenter = NetworkIssuesCenterImpl.shared

    private var currentConnection: SubstrateConnection?
    private var failedUrls: Set<URL?> = []

    public init(
        urls: [URL],
        selectedUrl: URL? = nil,
        chainId: ChainModel.Id
    ) {
        self.urls = urls
        selecteUrl = selectedUrl
        self.chainId = chainId
    }

    // MARK: - Public methods

    public func getActiveStatus() async -> Bool {
        isActive
    }

    public func connection() async throws -> SubstrateConnection {
        guard let connection = currentConnection else {
            return try await setupConnection(ignoredUrl: nil)
        }
        return connection
    }

    // MARK: - Private methods

    private func setupConnection(
        ignoredUrl: URL?
    ) async throws -> SubstrateConnection {
        if ignoredUrl == nil,
           let connection = currentConnection,
           await connection.getUrl()?.absoluteString == selecteUrl?.absoluteString
        {
            return connection
        }

        let node = selecteUrl ?? urls.first(where: {
            ($0 != ignoredUrl) && !failedUrls.contains($0)
        })
        failedUrls.insert(ignoredUrl)

        guard let url = node else {
            throw ConnectionPoolError.onlyOneNode
        }

        if let connection = currentConnection {
            if await connection.getUrl() == url {
                return connection
            } else if ignoredUrl != nil {
                await connection.reconnect(url: url)
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
        from _: WebSocketEngine.State,
        to newState: WebSocketEngine.State
    ) async {
        guard selecteUrl == nil,
              let previousUrl = await engine.getUrl() else
        {
            return
        }

        switch newState {
        case let .waitingReconnection(attempt: attempt):
            isActive = true
            if attempt > NetworkConstants.websocketReconnectAttemptsLimit {
                _ = try? await setupConnection(ignoredUrl: previousUrl)
            }
        case .notConnected:
            isActive = false
        default:
            isActive = true
        }

        connectionIssuesCenter.handle(chain: chainId, state: newState)
    }
}
