import Foundation
import RobinHood

enum JSONRPCOperationError: Error {
    case timeout
}

public class JSONRPCOperation<P: Codable, T: Decodable>: BaseOperation<T> {
    public let engine: JSONRPCEngine
    private let requestLock = NSLock()
    private var currentRequestId: UInt16?
    private(set) var requestId: UInt16? {
        get { requestLock.lock(); defer { requestLock.unlock() }; return currentRequestId }
        set { requestLock.lock(); currentRequestId = newValue; requestLock.unlock() }
    }
    public let requestOptions: JSONRPCOptions
    public let method: String
    public var parameters: P?
    public let timeout: Int

    public init(engine: JSONRPCEngine, method: String, parameters: P? = nil, timeout: Int = 10,
                requestOptions: JSONRPCOptions = JSONRPCOptions()) {
        self.engine = engine
        self.method = method
        self.parameters = parameters
        self.timeout = timeout
        self.requestOptions = requestOptions

        super.init()
    }

    override public func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            let semaphore = DispatchSemaphore(value: 0)

            var optionalCallResult: Result<T, Error>?

            requestId = try engine.callMethod(method, params: parameters, options: requestOptions) { (result: Result<
                T,
                Error
            >) in
                optionalCallResult = result

                semaphore.signal()
            }

            // Cancellation may race with the synchronous request enqueue.
            // Publish the ID first, then cancel again if that race occurred.
            if isCancelled, let identifier = requestId {
                engine.cancelForIdentifier(identifier)
                return
            }

            let status = semaphore.wait(timeout: .now() + .seconds(timeout))

            if status == .timedOut {
                if requestOptions.writeAuthorization != nil {
                    if let identifier = requestId { engine.cancelForIdentifier(identifier) }
                    // The protocol's cancellation API cannot prove whether the
                    // transport accepted bytes. Require reconciliation, never retry.
                    result = .failure(JSONRPCEngineError.submissionOutcomeUnknown)
                } else {
                    result = .failure(JSONRPCOperationError.timeout)
                }
                return
            }

            guard let callResult = optionalCallResult else {
                return
            }

            if case let .failure(error) = callResult,
               let jsonRPCEngineError = error as? JSONRPCEngineError,
               jsonRPCEngineError == .clientCancelled
            {
                return
            }

            switch callResult {
            case let .success(response):
                result = .success(response)
            case let .failure(error):
                result = .failure(error)
            }

        } catch {
            result = .failure(error)
        }
    }

    override public func cancel() {
        super.cancel()
        if let requestId = requestId {
            engine.cancelForIdentifier(requestId)
        }

    }
}

public final class JSONRPCListOperation<T: Decodable>: JSONRPCOperation<[String], T> {}

public extension JSONRPCOperation {
    static func failureOperation(_ error: Error) -> JSONRPCOperation<P, T> {
        let mockEngine = WebSocketEngine(
            connectionName: nil,
            url: URL(string: "https://wiki.fearlesswallet.io")!,
            autoconnect: false
        )
        let operation = JSONRPCOperation<P, T>(engine: mockEngine, method: "")
        operation.result = .failure(error)
        return operation
    }
}
