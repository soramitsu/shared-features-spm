import Foundation
import RobinHood
import SSFUtils

public typealias RuntimeMetadataClosure = () throws -> RuntimeMetadata

public enum RuntimeSpecVersion: UInt32 {
    case v9370 = 9370
    case v9380 = 9380
    case v9390 = 9390
    case v9420 = 9420

    public static let defaultVersion: RuntimeSpecVersion = .v9390

    public init?(rawValue: UInt32) {
        switch rawValue {
        case 9370:
            self = .v9370
        case 9380:
            self = .v9380
        case 9390:
            self = .v9390
        case 9420:
            self = .v9420
        default:
            self = RuntimeSpecVersion.defaultVersion
        }
    }

    // Helper methods

    public func higherOrEqualThan(_ version: RuntimeSpecVersion) -> Bool {
        rawValue >= version.rawValue
    }

    public func lowerOrEqualThan(_ version: RuntimeSpecVersion) -> Bool {
        rawValue <= version.rawValue
    }
}


// sourcery: AutoMockable
public protocol RuntimeCodingServiceProtocol {
    var snapshot: RuntimeSnapshot? { get }

    func fetchCoderFactoryOperation() -> BaseOperation<RuntimeCoderFactoryProtocol>
    func fetchCoderFactory() async throws -> RuntimeCoderFactoryProtocol
}

public protocol RuntimeProviderProtocol: AnyObject, RuntimeCodingServiceProtocol {
    var runtimeSpecVersion: RuntimeSpecVersion { get }

    func setup()
    func readySnapshot() async throws -> RuntimeSnapshot
    func cleanup()
    func setupHot()
}
