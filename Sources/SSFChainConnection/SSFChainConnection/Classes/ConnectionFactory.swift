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
        let engine = try WebSocketEngine(
            connectionName: connectionName,
            urls: urls,
            processingQueue: processingQueue,
            logger: nil
        )
        engine.delegate = delegate
        return engine
    }
}
