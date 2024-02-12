// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFUtils
@testable import SSFCrypto
@testable import SSFModels
@testable import RobinHood
@testable import SSFExtrinsicKit
@testable import IrohaCrypto
@testable import SSFRuntimeCodingService
@testable import SSFSigner

class ExtrinsicServiceProtocolMock: ExtrinsicServiceProtocol {

    //MARK: - estimateFee

    var estimateFeeRunningInCompletionCallsCount = 0
    var estimateFeeRunningInCompletionCalled: Bool {
        return estimateFeeRunningInCompletionCallsCount > 0
    }
    var estimateFeeRunningInCompletionReceivedArguments: (closure: ExtrinsicBuilderClosure, queue: DispatchQueue, completionClosure: EstimateFeeClosure)?
    var estimateFeeRunningInCompletionReceivedInvocations: [(closure: ExtrinsicBuilderClosure, queue: DispatchQueue, completionClosure: EstimateFeeClosure)] = []
    var estimateFeeRunningInCompletionClosure: ((@escaping ExtrinsicBuilderClosure, DispatchQueue, @escaping EstimateFeeClosure) -> Void)?

    func estimateFee(_ closure: @escaping ExtrinsicBuilderClosure, runningIn queue: DispatchQueue, completion completionClosure: @escaping EstimateFeeClosure) {
        estimateFeeRunningInCompletionCallsCount += 1
        estimateFeeRunningInCompletionReceivedArguments = (closure: closure, queue: queue, completionClosure: completionClosure)
        estimateFeeRunningInCompletionReceivedInvocations.append((closure: closure, queue: queue, completionClosure: completionClosure))
        estimateFeeRunningInCompletionClosure?(closure, queue, completionClosure)
    }

    //MARK: - estimateFee

    var estimateFeeRunningInNumberOfExtrinsicsCompletionCallsCount = 0
    var estimateFeeRunningInNumberOfExtrinsicsCompletionCalled: Bool {
        return estimateFeeRunningInNumberOfExtrinsicsCompletionCallsCount > 0
    }
    var estimateFeeRunningInNumberOfExtrinsicsCompletionReceivedArguments: (closure: ExtrinsicBuilderIndexedClosure, queue: DispatchQueue, numberOfExtrinsics: Int, completionClosure: EstimateFeeIndexedClosure)?
    var estimateFeeRunningInNumberOfExtrinsicsCompletionReceivedInvocations: [(closure: ExtrinsicBuilderIndexedClosure, queue: DispatchQueue, numberOfExtrinsics: Int, completionClosure: EstimateFeeIndexedClosure)] = []
    var estimateFeeRunningInNumberOfExtrinsicsCompletionClosure: ((@escaping ExtrinsicBuilderIndexedClosure, DispatchQueue, Int, @escaping EstimateFeeIndexedClosure) -> Void)?

    func estimateFee(_ closure: @escaping ExtrinsicBuilderIndexedClosure, runningIn queue: DispatchQueue, numberOfExtrinsics: Int, completion completionClosure: @escaping EstimateFeeIndexedClosure) {
        estimateFeeRunningInNumberOfExtrinsicsCompletionCallsCount += 1
        estimateFeeRunningInNumberOfExtrinsicsCompletionReceivedArguments = (closure: closure, queue: queue, numberOfExtrinsics: numberOfExtrinsics, completionClosure: completionClosure)
        estimateFeeRunningInNumberOfExtrinsicsCompletionReceivedInvocations.append((closure: closure, queue: queue, numberOfExtrinsics: numberOfExtrinsics, completionClosure: completionClosure))
        estimateFeeRunningInNumberOfExtrinsicsCompletionClosure?(closure, queue, numberOfExtrinsics, completionClosure)
    }

    //MARK: - submit

    var submitSignerRunningInCompletionCallsCount = 0
    var submitSignerRunningInCompletionCalled: Bool {
        return submitSignerRunningInCompletionCallsCount > 0
    }
    var submitSignerRunningInCompletionReceivedArguments: (closure: ExtrinsicBuilderClosure, signer: TransactionSignerProtocol, queue: DispatchQueue, completionClosure: ExtrinsicSubmitClosure)?
    var submitSignerRunningInCompletionReceivedInvocations: [(closure: ExtrinsicBuilderClosure, signer: TransactionSignerProtocol, queue: DispatchQueue, completionClosure: ExtrinsicSubmitClosure)] = []
    var submitSignerRunningInCompletionClosure: ((@escaping ExtrinsicBuilderClosure, TransactionSignerProtocol, DispatchQueue, @escaping ExtrinsicSubmitClosure) -> Void)?

    func submit(_ closure: @escaping ExtrinsicBuilderClosure, signer: TransactionSignerProtocol, runningIn queue: DispatchQueue, completion completionClosure: @escaping ExtrinsicSubmitClosure) {
        submitSignerRunningInCompletionCallsCount += 1
        submitSignerRunningInCompletionReceivedArguments = (closure: closure, signer: signer, queue: queue, completionClosure: completionClosure)
        submitSignerRunningInCompletionReceivedInvocations.append((closure: closure, signer: signer, queue: queue, completionClosure: completionClosure))
        submitSignerRunningInCompletionClosure?(closure, signer, queue, completionClosure)
    }

    //MARK: - submit

    var submitSignerRunningInNumberOfExtrinsicsCompletionCallsCount = 0
    var submitSignerRunningInNumberOfExtrinsicsCompletionCalled: Bool {
        return submitSignerRunningInNumberOfExtrinsicsCompletionCallsCount > 0
    }
    var submitSignerRunningInNumberOfExtrinsicsCompletionReceivedArguments: (closure: ExtrinsicBuilderIndexedClosure, signer: TransactionSignerProtocol, queue: DispatchQueue, numberOfExtrinsics: Int, completionClosure: ExtrinsicSubmitIndexedClosure)?
    var submitSignerRunningInNumberOfExtrinsicsCompletionReceivedInvocations: [(closure: ExtrinsicBuilderIndexedClosure, signer: TransactionSignerProtocol, queue: DispatchQueue, numberOfExtrinsics: Int, completionClosure: ExtrinsicSubmitIndexedClosure)] = []
    var submitSignerRunningInNumberOfExtrinsicsCompletionClosure: ((@escaping ExtrinsicBuilderIndexedClosure, TransactionSignerProtocol, DispatchQueue, Int, @escaping ExtrinsicSubmitIndexedClosure) -> Void)?

    func submit(_ closure: @escaping ExtrinsicBuilderIndexedClosure, signer: TransactionSignerProtocol, runningIn queue: DispatchQueue, numberOfExtrinsics: Int, completion completionClosure: @escaping ExtrinsicSubmitIndexedClosure) {
        submitSignerRunningInNumberOfExtrinsicsCompletionCallsCount += 1
        submitSignerRunningInNumberOfExtrinsicsCompletionReceivedArguments = (closure: closure, signer: signer, queue: queue, numberOfExtrinsics: numberOfExtrinsics, completionClosure: completionClosure)
        submitSignerRunningInNumberOfExtrinsicsCompletionReceivedInvocations.append((closure: closure, signer: signer, queue: queue, numberOfExtrinsics: numberOfExtrinsics, completionClosure: completionClosure))
        submitSignerRunningInNumberOfExtrinsicsCompletionClosure?(closure, signer, queue, numberOfExtrinsics, completionClosure)
    }

    //MARK: - submitAndWatch

    var submitAndWatchSignerRunningInCompletionCallsCount = 0
    var submitAndWatchSignerRunningInCompletionCalled: Bool {
        return submitAndWatchSignerRunningInCompletionCallsCount > 0
    }
    var submitAndWatchSignerRunningInCompletionReceivedArguments: (closure: ExtrinsicBuilderClosure, signer: TransactionSignerProtocol, queue: DispatchQueue, completionClosure: ExtrinsicSubmitAndWatchClosure)?
    var submitAndWatchSignerRunningInCompletionReceivedInvocations: [(closure: ExtrinsicBuilderClosure, signer: TransactionSignerProtocol, queue: DispatchQueue, completionClosure: ExtrinsicSubmitAndWatchClosure)] = []
    var submitAndWatchSignerRunningInCompletionClosure: ((@escaping ExtrinsicBuilderClosure, TransactionSignerProtocol, DispatchQueue, @escaping ExtrinsicSubmitAndWatchClosure) -> Void)?

    func submitAndWatch(_ closure: @escaping ExtrinsicBuilderClosure, signer: TransactionSignerProtocol, runningIn queue: DispatchQueue, completion completionClosure: @escaping ExtrinsicSubmitAndWatchClosure) {
        submitAndWatchSignerRunningInCompletionCallsCount += 1
        submitAndWatchSignerRunningInCompletionReceivedArguments = (closure: closure, signer: signer, queue: queue, completionClosure: completionClosure)
        submitAndWatchSignerRunningInCompletionReceivedInvocations.append((closure: closure, signer: signer, queue: queue, completionClosure: completionClosure))
        submitAndWatchSignerRunningInCompletionClosure?(closure, signer, queue, completionClosure)
    }

}
