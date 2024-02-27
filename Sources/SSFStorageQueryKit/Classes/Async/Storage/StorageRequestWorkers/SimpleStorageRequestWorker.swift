import Foundation
import SSFRuntimeCodingService
import SSFUtils

final class SimpleStorageRequestWorker<P: Decodable>: StorageRequestWorker {
    private let runtimeService: RuntimeCodingServiceProtocol
    private let connection: JSONRPCEngine
    private let storageRequestFactory: AsyncStorageRequestFactory

    init(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine,
        storageRequestFactory: AsyncStorageRequestFactory
    ) {
        self.runtimeService = runtimeService
        self.connection = connection
        self.storageRequestFactory = storageRequestFactory
    }

    func perform<T>(request: some StorageRequest) async throws -> [StorageResponse<T>] where T : Decodable {
        guard case StorageRequestParametersType.simple = request.parametersType else {
            throw StorageRequestWorkerError.invalidParameters
        }

        let key = try StorageKeyFactory().createStorageKey(
            moduleName: request.storagePath.moduleName,
            storageName: request.storagePath.itemName
        )
        let coderFactory = try await runtimeService.fetchCoderFactory()
        let response: [StorageResponse<T>] = try await storageRequestFactory.queryItems(
            engine: connection,
            keys: [key],
            factory: coderFactory,
            storagePath: request.storagePath
        )
        return response
    }
}
