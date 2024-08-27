import Foundation
import SSFUtils

public typealias ChainConnection = JSONRPCEngine

public protocol ConnectionFactoryProtocol {
    func createConnection(
        connectionName: String?,
        for urls: [URL],
        delegate: WebSocketEngineDelegate
    ) throws -> ChainConnection
}

public final class ConnectionFactory: ConnectionFactoryProtocol {
    private lazy var processingQueue: DispatchQueue = .init(
        label: "jp.co.soramitsu.fearless.wallet.ws.SSFChainConnection",
        qos: .userInitiated
    )
    
    public init() {
        
    }
    
    public func createConnection(
        connectionName: String?,
        for urls: [URL],
        delegate: WebSocketEngineDelegate
    ) throws -> ChainConnection {
        guard let connectionStrategy = ConnectionStrategyImpl(
            urls: urls,
            callbackQueue: processingQueue
        ) else {
            throw ConnectionPoolError.noConnection
        }
        let engine = WebSocketEngine(
            connectionName: connectionName,
            connectionStrategy: connectionStrategy,
            processingQueue: processingQueue
        )
        engine.delegate = delegate
        return engine
    }
}
