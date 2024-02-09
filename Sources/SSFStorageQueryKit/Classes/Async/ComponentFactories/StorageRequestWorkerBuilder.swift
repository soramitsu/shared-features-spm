import Foundation
import SSFUtils
import SSFRuntimeCodingService

protocol StorageRequestWorkerBuilder {
    func buildWorker(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory,
        request: some StorageRequest
    ) -> StorageRequestWorker
}

final class StorageRequestWorkerBuilderDefault<T: Decodable>: StorageRequestWorkerBuilder {
    func buildWorker(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory,
        request: some StorageRequest
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
        case .keys:
            return KeysStorageRequestWorker<T>(
                runtimeService: runtimeService,
                connection: connection,
                storageRequestFactory: storageRequestFactory
            )
        }
    }
}
