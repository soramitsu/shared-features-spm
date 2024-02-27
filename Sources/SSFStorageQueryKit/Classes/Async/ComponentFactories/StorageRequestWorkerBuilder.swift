import Foundation
import SSFUtils
import SSFRuntimeCodingService

protocol StorageRequestWorkerBuilder {
    func buildWorker(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory,
        request: StorageRequest
    ) -> StorageRequestWorker
}

final class StorageRequestWorkerBuilderDefault<T: Decodable>: StorageRequestWorkerBuilder {
    func buildWorker(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory,
        request: StorageRequest
    ) -> StorageRequestWorker {
        switch request.parametersType {
        case .nMap:
            return NMapStorageRequestWorker<T>(
                runtimeService: runtimeService,
                connection: connection,
                storageRequestFactory: storageRequestFactory
            )
        case .encodable:
            return EncodableStorageRequestWorker<T>(
                runtimeService: runtimeService,
                connection: connection,
                storageRequestFactory: storageRequestFactory
            )
        case .simple:
            return SimpleStorageRequestWorker<T>(
                runtimeService: runtimeService,
                connection: connection,
                storageRequestFactory: storageRequestFactory
            )
        }
    }
}
