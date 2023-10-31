import Foundation
import RobinHood
import SSFUtils
import SSFRuntimeCodingService

public final class ImmortalEraOperationFactory: ExtrinsicEraOperationFactoryProtocol {
    public init() {}
    
    public func createOperation(
        from _: JSONRPCEngine,
        runtimeService _: RuntimeCodingServiceProtocol
    ) -> CompoundOperationWrapper<ExtrinsicEraParameters> {
        let parameters = ExtrinsicEraParameters(blockNumber: 0, extrinsicEra: .immortal)
        return CompoundOperationWrapper.createWithResult(parameters)
    }
}
