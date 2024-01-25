// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFQRService

class QREncoderMock: QREncoder {

    //MARK: - encode

    var encodeWithThrowableError: Error?
    var encodeWithCallsCount = 0
    var encodeWithCalled: Bool {
        return encodeWithCallsCount > 0
    }
    var encodeWithReceivedType: QRType?
    var encodeWithReceivedInvocations: [QRType] = []
    var encodeWithReturnValue: Data!
    var encodeWithClosure: ((QRType) throws -> Data)?

    func encode(with type: QRType) throws -> Data {
        if let error = encodeWithThrowableError {
            throw error
        }
        encodeWithCallsCount += 1
        encodeWithReceivedType = type
        encodeWithReceivedInvocations.append(type)
        return try encodeWithClosure.map({ try $0(type) }) ?? encodeWithReturnValue
    }

}
