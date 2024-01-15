import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFRuntimeCodingService

public struct ExtrinsicEraParameters {
    public let blockNumber: BlockNumber
    public let extrinsicEra: Era
}

public protocol ExtrinsicEraOperationFactoryProtocol {
    func createOperation(
        from connection: JSONRPCEngine,
        runtimeService: RuntimeCodingServiceProtocol
    ) -> CompoundOperationWrapper<ExtrinsicEraParameters>
}
