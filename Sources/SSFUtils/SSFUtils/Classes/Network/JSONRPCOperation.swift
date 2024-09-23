import Foundation
import RobinHood

enum JSONRPCOperationError: Error {
    case timeout
}

public class JSONRPCOperation<P: Codable, T: Decodable>: BaseOperation<T> {
    private let lockQueue = DispatchQueue(
        label: "com.soramitsu.asyncOperation",
        attributes: .concurrent
    )

    override public var isAsynchronous: Bool {
        true
    }

    private var _isExecuting: Bool = false
    override public private(set) var isExecuting: Bool {
        get {
            lockQueue.sync { () -> Bool in
                _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override public private(set) var isFinished: Bool {
        get {
            lockQueue.sync { () -> Bool in
                _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    public let engine: JSONRPCEngine
    private(set) var requestId: UInt16?
    public let method: String
    public var parameters: P?
    public let timeout: Int

    public init(engine: JSONRPCEngine, method: String, parameters: P? = nil, timeout: Int = 10) {
        self.engine = engine
        self.method = method
        self.parameters = parameters
        self.timeout = timeout

        super.init()
    }

    override public func start() {
        super.start()
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    override public func main() {
        super.main()

        if isCancelled {
            finish()
            return
        }

        Task {
            do {
                let semaphore = DispatchSemaphore(value: 0)

                var optionalCallResult: Result<T, Error>?

                requestId = try await engine
                    .callMethod(method, params: parameters) { (result: Result<
                        T,
                        Error
                    >) in
                        optionalCallResult = result
                        semaphore.signal()
                    }

                guard let callResult = optionalCallResult else {
                    finish()
                    return
                }

                if case let .failure(error) = callResult,
                   let jsonRPCEngineError = error as? JSONRPCEngineError,
                   jsonRPCEngineError == .clientCancelled
                {
                    finish()
                    return
                }

                switch callResult {
                case let .success(response):
                    result = .success(response)
                    finish()
                case let .failure(error):
                    result = .failure(error)
                    finish()
                }

            } catch {
                result = .failure(error)
                finish()
            }
        }
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }

    override public func cancel() {
        Task {
            if let requestId = requestId {
                await engine.cancelForIdentifier(requestId)
            }
        }
        super.cancel()
    }
}

public final class JSONRPCListOperation<T: Decodable>: JSONRPCOperation<[String], T> {}

public extension JSONRPCOperation {
    static func failureOperation(_ error: Error) -> JSONRPCOperation<P, T> {
        let mockEngine = WebSocketEngine(
            connectionName: nil,
            url: URL(string: "https://wiki.fearlesswallet.io")!,
            autoconnect: false,
            delegate: nil
        )
        let operation = JSONRPCOperation<P, T>(engine: mockEngine, method: "")
        operation.result = .failure(error)
        return operation
    }
}
