// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFQRService

class QRDecoderMock: QRDecoder {

    //MARK: - decode

    var decodeDataThrowableError: Error?
    var decodeDataCallsCount = 0
    var decodeDataCalled: Bool {
        return decodeDataCallsCount > 0
    }
    var decodeDataReceivedData: Data?
    var decodeDataReceivedInvocations: [Data] = []
    var decodeDataReturnValue: QRInfoType!
    var decodeDataClosure: ((Data) throws -> QRInfoType)?

    func decode(data: Data) throws -> QRInfoType {
        if let error = decodeDataThrowableError {
            throw error
        }
        decodeDataCallsCount += 1
        decodeDataReceivedData = data
        decodeDataReceivedInvocations.append(data)
        return try decodeDataClosure.map({ try $0(data) }) ?? decodeDataReturnValue
    }

}
