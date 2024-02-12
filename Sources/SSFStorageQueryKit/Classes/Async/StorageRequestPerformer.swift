import Foundation
import SSFUtils
import SSFRuntimeCodingService

public protocol StorageRequestPerformer {
    func performRequest<T: Decodable>(_ request: any StorageRequest) async throws -> T?
}

public final class StorageRequestPerformerDefault: StorageRequestPerformer {
    private let runtimeService: RuntimeCodingServiceProtocol
    private let connection: JSONRPCEngine
    private lazy var storageRequestFactory: AsyncStorageRequestFactory = {
        AsyncStorageRequestDefault()
    }()

    public init(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine
    ) {
        self.runtimeService = runtimeService
        self.connection = connection
    }
    
    public func performRequest<T: Decodable>(_ request: any StorageRequest) async throws -> T? {
        let worker = StorageRequestWorkerBuilderDefault<T>().buildWorker(
            runtimeService: runtimeService,
            connection: connection,
            storageRequestFactory: storageRequestFactory,
            request: request
        )

        let responseDecoder = StorageSingleResponseDecoder()
        let response: [StorageResponse<T>] = try await worker.perform(request: request)
        let decoded = try responseDecoder.decode(storageResponse: response)

        return decoded
    }
}
