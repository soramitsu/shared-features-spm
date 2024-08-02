import Foundation
import SSFRuntimeCodingService
import SSFUtils

protocol StorageRequestWorkerBuilder {
    func buildWorker(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory,
        type: StorageRequestWorkerType
    ) -> StorageRequestWorker
}

public enum StorageRequestWorkerType {
    case nMap(params: [[any NMapKeyParamProtocol]])
    case encodable(params: [any Encodable])
    case simple
}

final class StorageRequestWorkerBuilderDefault<T: Decodable>: StorageRequestWorkerBuilder {
    func buildWorker(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory,
        type: StorageRequestWorkerType
    ) -> StorageRequestWorker {
        switch type {
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
