// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFUtils
@testable import BigInt

class ReconnectionStrategyProtocolMock: ReconnectionStrategyProtocol {

    //MARK: - reconnectAfter

    var reconnectAfterAttemptCallsCount = 0
    var reconnectAfterAttemptCalled: Bool {
        return reconnectAfterAttemptCallsCount > 0
    }
    var reconnectAfterAttemptReceivedAttempt: Int?
    var reconnectAfterAttemptReceivedInvocations: [Int] = []
    var reconnectAfterAttemptReturnValue: TimeInterval?
    var reconnectAfterAttemptClosure: ((Int) -> TimeInterval?)?

    func reconnectAfter(attempt: Int) -> TimeInterval? {
        reconnectAfterAttemptCallsCount += 1
        reconnectAfterAttemptReceivedAttempt = attempt
        reconnectAfterAttemptReceivedInvocations.append(attempt)
        return reconnectAfterAttemptClosure.map({ $0(attempt) }) ?? reconnectAfterAttemptReturnValue
    }

}
