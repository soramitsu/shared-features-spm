// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFQRService

class QRMatcherMock: QRMatcher {

    //MARK: - match

    var matchCodeCallsCount = 0
    var matchCodeCalled: Bool {
        return matchCodeCallsCount > 0
    }
    var matchCodeReceivedCode: String?
    var matchCodeReceivedInvocations: [String] = []
    var matchCodeReturnValue: QRMatcherType?
    var matchCodeClosure: ((String) -> QRMatcherType?)?

    func match(code: String) -> QRMatcherType? {
        matchCodeCallsCount += 1
        matchCodeReceivedCode = code
        matchCodeReceivedInvocations.append(code)
        return matchCodeClosure.map({ $0(code) }) ?? matchCodeReturnValue
    }

}
