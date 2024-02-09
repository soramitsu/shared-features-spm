import Foundation
import SSFUtils
import RobinHood

public typealias RuntimeMetadataClosure = () throws -> RuntimeMetadata

public protocol RuntimeCodingServiceProtocol {
    var snapshot: RuntimeSnapshot? { get }

    func fetchCoderFactoryOperation() -> BaseOperation<RuntimeCoderFactoryProtocol>
    func fetchCoderFactory() async throws -> RuntimeCoderFactoryProtocol
}
