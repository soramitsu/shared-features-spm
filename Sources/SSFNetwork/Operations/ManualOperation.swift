import Foundation
import RobinHood

public final class ManualOperation<ResultType>: BaseOperation<ResultType> {
    private let lockQueue = DispatchQueue(
        label: "jp.co.soramitsu.asyncoperation",
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

    override public func start() {
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

        if result != nil {
            finish()
            return
        }
    }

    public func finish() {
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }
}
