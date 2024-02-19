import Foundation
import RobinHood
import SSFUtils

public typealias RuntimeMetadataClosure = () throws -> RuntimeMetadata

public protocol RuntimeCodingServiceProtocol {
    var snapshot: RuntimeSnapshot? { get }

    func fetchCoderFactoryOperation() -> BaseOperation<RuntimeCoderFactoryProtocol>
}
