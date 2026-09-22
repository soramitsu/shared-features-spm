import Foundation
import Starscream

extension WebSocketEngine: JSONRPCEngine {
    public var pendingEngineRequests: [JSONRPCRequest] {
        pendingRequests
    }

    public func callMethod<P: Codable, T: Decodable>(
        _ method: String,
        params: P?,
        options: JSONRPCOptions,
        completion closure: ((Result<T, Error>) -> Void)?
    ) throws -> UInt16 {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        let request = try prepareRequest(
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
    ) throws -> UInt16 {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        let completion: ((Result<String, Error>) -> Void)? = nil

        let request = try prepareRequest(
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

        addSubscription(subscription)

        updateConnectionForRequest(request)

        return request.requestId
    }

    public func cancelForIdentifier(_ identifier: UInt16) {
        mutex.lock()

        cancelRequestForLocalId(identifier)

        mutex.unlock()
    }

    public func reconnect(url: URL) {
        mutex.lock()
        cancelPendingGuardedRequests()
        let cancelled = resetInProgress()
        notify(requests: cancelled, error: JSONRPCEngineError.remoteCancelled)
        let previous = connection
        previous.delegate = nil
        reconnectionScheduler.cancel()
        pingScheduler.cancel()
        self.url = url
        let request = URLRequest(url: url, timeoutInterval: 10)
        // Reusing an already-connected engine would send a new URL's requests
        // to the previous socket. A new endpoint requires a new handshake.
        let engine = WSEngine(transport: TCPTransport(), certPinner: FoundationSecurity())
        let next = WebSocket(request: request, engine: engine)
        next.callbackQueue = completionQueue
        next.delegate = self
        connection = next
        changeState(.notConnected)
        mutex.unlock()
        // No library writer wait occurs while holding the RPC request mutex.
        previous.forceDisconnect()
    }
}
