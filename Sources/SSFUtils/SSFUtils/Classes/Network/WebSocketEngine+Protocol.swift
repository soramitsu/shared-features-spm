import Foundation
import Starscream

extension WebSocketEngine: JSONRPCEngine {
    public func getPendingEngineRequests() async -> [JSONRPCRequest] {
        pendingRequests
    }

    public func callMethod<P: Codable, T: Decodable>(
        _ method: String,
        params: P?,
        options: JSONRPCOptions,
        completion closure: ((Result<T, Error>) -> Void)?
    ) async throws -> UInt16 {
        let request = try await prepareRequest(
            method: method,
            params: params,
            options: options,
            completion: closure
        )

        updateConnectionForRequest(request)

        return request.requestId
    }

    public func subscribe<P: Codable, T: Decodable>(
        _ method: String,
        params: P?,
        updateClosure: @escaping (T) -> Void,
        failureClosure: @escaping (Error, Bool) -> Void
    ) async throws -> UInt16 {
        let completion: ((Result<String, Error>) -> Void)? = nil

        let request = try await prepareRequest(
            method: method,
            params: params,
            options: JSONRPCOptions(resendOnReconnect: true),
            completion: completion
        )

        let subscription = JSONRPCSubscription(
            requestId: request.requestId,
            requestData: request.data,
            requestOptions: request.options,
            updateClosure: updateClosure,
            failureClosure: failureClosure
        )

        await addSubscription(subscription)

        updateConnectionForRequest(request)

        return request.requestId
    }

    public func cancelForIdentifier(_ identifier: UInt16) async {
        cancelRequestForLocalId(identifier)
    }

    public func reconnect(url: URL) async {
        self.connection.delegate = nil

        self.url = url
        let request = URLRequest(url: url, timeoutInterval: 10)
        let engine = self.connection.engine

        let connection = WebSocket(request: request, engine: engine)
        self.connection = connection

        connection.callbackQueue = Self.sharedProcessingQueue
        connection.delegate = self
    }
}
