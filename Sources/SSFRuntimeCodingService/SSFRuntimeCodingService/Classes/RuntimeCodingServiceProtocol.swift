import Foundation
import SSFUtils
import RobinHood

public typealias RuntimeMetadataClosure = () throws -> RuntimeMetadata

public protocol RuntimeCodingServiceProtocol {
    var snapshot: RuntimeSnapshot? { get }

    func fetchCoderFactoryOperation(
        with timeout: TimeInterval,
        closure: RuntimeMetadataClosure?
    ) -> BaseOperation<RuntimeCoderFactoryProtocol>
}

public extension RuntimeCodingServiceProtocol {
    func fetchCoderFactoryOperation(with timeout: TimeInterval) -> BaseOperation<RuntimeCoderFactoryProtocol> {
        fetchCoderFactoryOperation(with: timeout, closure: nil)
    }

    func fetchCoderFactoryOperation() -> BaseOperation<RuntimeCoderFactoryProtocol> {
        fetchCoderFactoryOperation(with: 20, closure: nil)
    }
}
