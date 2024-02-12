import UIKit
@testable import SSFUtils
@testable import BigInt

class RuntimeMetadataProtocolMock: RuntimeMetadataProtocol {
    var schema: Schema?
    var modules: [RuntimeModuleMetadata] = []
    var extrinsic: RuntimeExtrinsicMetadata {
        get { return underlyingExtrinsic }
        set(value) { underlyingExtrinsic = value }
    }
    var underlyingExtrinsic: RuntimeExtrinsicMetadata!

    //MARK: - init
    
    public init(schema: Schema?,
                modules: [RuntimeModuleMetadata],
                extrinsic: RuntimeExtrinsicMetadata) {
        self.schema = schema
        self.modules = modules
        self.underlyingExtrinsic = extrinsic
    }

    var initScaleDecoderThrowableError: Error?
    var initScaleDecoderReceivedScaleDecoder: ScaleDecoding?
    var initScaleDecoderReceivedInvocations: [ScaleDecoding] = []
    var initScaleDecoderClosure: ((ScaleDecoding) throws -> Void)?

    required init(scaleDecoder: ScaleDecoding) throws {
        initScaleDecoderReceivedScaleDecoder = scaleDecoder
        initScaleDecoderReceivedInvocations.append(scaleDecoder)
        try initScaleDecoderClosure?(scaleDecoder)
    }
    //MARK: - encode

    var encodeScaleEncoderThrowableError: Error?
    var encodeScaleEncoderCallsCount = 0
    var encodeScaleEncoderCalled: Bool {
        return encodeScaleEncoderCallsCount > 0
    }
    var encodeScaleEncoderReceivedScaleEncoder: ScaleEncoding?
    var encodeScaleEncoderReceivedInvocations: [ScaleEncoding] = []
    var encodeScaleEncoderClosure: ((ScaleEncoding) throws -> Void)?

    func encode(scaleEncoder: ScaleEncoding) throws {
        if let error = encodeScaleEncoderThrowableError {
            throw error
        }
        encodeScaleEncoderCallsCount += 1
        encodeScaleEncoderReceivedScaleEncoder = scaleEncoder
        encodeScaleEncoderReceivedInvocations.append(scaleEncoder)
        try encodeScaleEncoderClosure?(scaleEncoder)
    }

}
