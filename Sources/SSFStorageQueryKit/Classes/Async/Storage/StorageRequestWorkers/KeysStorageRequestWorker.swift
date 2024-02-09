import Foundation
import SSFRuntimeCodingService
import SSFUtils

final class KeysStorageRequestWorker<P: Decodable>: StorageRequestWorker {
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
        guard case let StorageRequestParametersType.keys(params: params) = request.parametersType else {
            throw StorageRequestWorkerError.invalidParameters
        }

        let coderFactory = try await runtimeService.fetchCoderFactory()
        let response: [StorageResponse<T>] = try await storageRequestFactory.queryItems(
            engine: connection,
            keys: params,
            factory: coderFactory,
            storagePath: request.storagePath
        )
        return response
    }
}
