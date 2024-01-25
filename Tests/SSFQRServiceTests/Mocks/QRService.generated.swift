// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFQRService

class QRServiceMock: QRService {

    //MARK: - extractQrCode

    var extractQrCodeFromThrowableError: Error?
    var extractQrCodeFromCallsCount = 0
    var extractQrCodeFromCalled: Bool {
        return extractQrCodeFromCallsCount > 0
    }
    var extractQrCodeFromReceivedImage: UIImage?
    var extractQrCodeFromReceivedInvocations: [UIImage] = []
    var extractQrCodeFromReturnValue: QRMatcherType!
    var extractQrCodeFromClosure: ((UIImage) throws -> QRMatcherType)?

    func extractQrCode(from image: UIImage) throws -> QRMatcherType {
        if let error = extractQrCodeFromThrowableError {
            throw error
        }
        extractQrCodeFromCallsCount += 1
        extractQrCodeFromReceivedImage = image
        extractQrCodeFromReceivedInvocations.append(image)
        return try extractQrCodeFromClosure.map({ try $0(image) }) ?? extractQrCodeFromReturnValue
    }

    //MARK: - generate

    var generateWithQrSizeThrowableError: Error?
    var generateWithQrSizeCallsCount = 0
    var generateWithQrSizeCalled: Bool {
        return generateWithQrSizeCallsCount > 0
    }
    var generateWithQrSizeReceivedArguments: (qrType: QRType, qrSize: CGSize)?
    var generateWithQrSizeReceivedInvocations: [(qrType: QRType, qrSize: CGSize)] = []
    var generateWithQrSizeReturnValue: UIImage!
    var generateWithQrSizeClosure: ((QRType, CGSize) throws -> UIImage)?

    func generate(with qrType: QRType, qrSize: CGSize) throws -> UIImage {
        if let error = generateWithQrSizeThrowableError {
            throw error
        }
        generateWithQrSizeCallsCount += 1
        generateWithQrSizeReceivedArguments = (qrType: qrType, qrSize: qrSize)
        generateWithQrSizeReceivedInvocations.append((qrType: qrType, qrSize: qrSize))
        return try generateWithQrSizeClosure.map({ try $0(qrType, qrSize) }) ?? generateWithQrSizeReturnValue
    }

}
