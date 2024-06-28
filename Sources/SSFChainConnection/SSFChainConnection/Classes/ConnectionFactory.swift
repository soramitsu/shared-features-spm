import Foundation
import SSFUtils

protocol ConnectionFactoryProtocol {
    func createConnection(
        connectionName: String?,
        for urls: [URL],
        delegate: WebSocketEngineDelegate
    ) throws -> SubstrateConnection
}

final class ConnectionFactory: ConnectionFactoryProtocol {
    private lazy var processingQueue: DispatchQueue = .init(
        label: "jp.co.soramitsu.fearless.wallet.ws.SSFChainConnection",
        qos: .userInitiated
    )

    func createConnection(
        connectionName: String?,
        for urls: [URL],
        delegate: WebSocketEngineDelegate
    ) throws -> SubstrateConnection {
        guard let connectionStrategy = ConnectionStrategyImpl(
            urls: urls,
            callbackQueue: processingQueue
        ) else {
            throw ConnectionPoolError.connectionFetchingError
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
