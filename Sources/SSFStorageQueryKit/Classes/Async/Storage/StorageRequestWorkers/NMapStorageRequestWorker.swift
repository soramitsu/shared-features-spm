import Foundation
import SSFUtils
import SSFRuntimeCodingService

final class NMapStorageRequestWorker<P: Decodable>: StorageRequestWorker {
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
    
    func perform<T: Decodable>(request: some StorageRequest) async throws -> [StorageResponse<T>] {
        guard case let StorageRequestParametersType.nMap(params: params) = request.parametersType else {
            throw StorageRequestWorkerError.invalidParameters
        }
        
        let coderFactoryOperation = try await runtimeService.fetchCoderFactory()
        let response: [StorageResponse<T>] = try await storageRequestFactory.queryItems(
            engine: connection,
            keyParams: [params],
            factory: coderFactoryOperation,
            storagePath: request.storagePath
        )
        return response
    }
}
