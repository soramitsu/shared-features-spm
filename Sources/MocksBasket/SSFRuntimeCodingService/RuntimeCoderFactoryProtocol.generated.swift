// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFRuntimeCodingService
@testable import SSFUtils
@testable import RobinHood
@testable import SSFModels

public class RuntimeCoderFactoryProtocolMock: RuntimeCoderFactoryProtocol {
public init() {}
    public var specVersion: UInt32 {
        get { return underlyingSpecVersion }
        set(value) { underlyingSpecVersion = value }
    }
    public var underlyingSpecVersion: UInt32!
    public var txVersion: UInt32 {
        get { return underlyingTxVersion }
        set(value) { underlyingTxVersion = value }
    }
    public var underlyingTxVersion: UInt32!
    public var metadata: RuntimeMetadata {
        get { return underlyingMetadata }
        set(value) { underlyingMetadata = value }
    }
    public var underlyingMetadata: RuntimeMetadata!

    //MARK: - createEncoder

    public var createEncoderCallsCount = 0
    public var createEncoderCalled: Bool {
        return createEncoderCallsCount > 0
    }
    public var createEncoderReturnValue: DynamicScaleEncoding!
    public var createEncoderClosure: (() -> DynamicScaleEncoding)?

    public func createEncoder() -> DynamicScaleEncoding {
        createEncoderCallsCount += 1
        return createEncoderClosure.map({ $0() }) ?? createEncoderReturnValue
    }

    //MARK: - createDecoder

    public var createDecoderFromThrowableError: Error?
    public var createDecoderFromCallsCount = 0
    public var createDecoderFromCalled: Bool {
        return createDecoderFromCallsCount > 0
    }
    public var createDecoderFromReceivedData: Data?
    public var createDecoderFromReceivedInvocations: [Data] = []
    public var createDecoderFromReturnValue: DynamicScaleDecoding!
    public var createDecoderFromClosure: ((Data) throws -> DynamicScaleDecoding)?

    public func createDecoder(from data: Data) throws -> DynamicScaleDecoding {
        if let error = createDecoderFromThrowableError {
            throw error
        }
        createDecoderFromCallsCount += 1
        createDecoderFromReceivedData = data
        createDecoderFromReceivedInvocations.append(data)
        return try createDecoderFromClosure.map({ try $0(data) }) ?? createDecoderFromReturnValue
    }

}
