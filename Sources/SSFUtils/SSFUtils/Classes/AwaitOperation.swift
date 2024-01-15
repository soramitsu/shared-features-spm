import Foundation
import RobinHood

public final class AwaitOperation<ResultType>: BaseOperation<ResultType> {
    private lazy var lockQueue: DispatchQueue = {
        DispatchQueue(label: "co.jp.soramitsu.ssfUtils.awaitOpeation", attributes: .concurrent)
    }()

    public override var isAsynchronous: Bool {
        true
    }

    private var _isExecuting: Bool = false
    public override private(set) var isExecuting: Bool {
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
    public override private(set) var isFinished: Bool {
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

    /// Closure to execute to produce operation result.
    public let closure: () async throws -> ResultType

    /**
     *  Create closure operation.
     *
     *  - parameters:
     *    - closure: Closure to execute to produce operation result.
     */

    public init(closure: @escaping () async throws -> ResultType) {
        self.closure = closure
    }

    public override func start() {
        isFinished = false
        isExecuting = true
        main()
    }

    public override func main() {
        super.main()

        if isCancelled {
            finish()
            return
        }

        if result != nil {
            finish()
            return
        }

        Task {
            do {
                let executionResult = try await closure()
                result = .success(executionResult)
                finish()
            } catch {
                result = .failure(error)
                finish()
            }
        }
    }

    private func finish() {
        isExecuting = false
        isFinished = true
    }
}
