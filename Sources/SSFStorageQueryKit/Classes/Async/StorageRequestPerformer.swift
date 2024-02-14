import Foundation
import SSFUtils
import SSFRuntimeCodingService
import SSFSingleValueCache
import RobinHood

public protocol StorageRequestPerformer {
    func performRequest<T: Decodable>(
        _ request: any StorageRequest
    ) async throws -> T?
    
    func performRequest<T: Decodable>(
        _ request: any StorageRequest,
        withCacheOptions: [CachedStorageRequestTrigger]
    ) async -> AsyncThrowingStream<T?, Error>
}

public final class StorageRequestPerformerDefault: StorageRequestPerformer {
    private let runtimeService: RuntimeCodingServiceProtocol
    private let connection: JSONRPCEngine
    private lazy var storageRequestFactory: AsyncStorageRequestFactory = {
        AsyncStorageRequestDefault()
    }()
    
    private var cacheStorage: SingleValueRepository {
        get throws {
            try SingleValueCacheRepositoryFactoryDefault().createSingleValueCasheRepository()
        }
    }
    
    private lazy var storageRequestKeyFactory: StorageRequestKeyFactory = {
        StorageRequestKeyFactoryDefault()
    }()

    public init(
        runtimeService: RuntimeCodingServiceProtocol,
        connection: JSONRPCEngine
    ) {
        self.runtimeService = runtimeService
        self.connection = connection
    }
    
    // MARK: - StorageRequestPerformer
    
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
        save(data: response.first?.data, for: request)

        return decoded
    }
    
    public func performRequest<T: Decodable>(
        _ request: any StorageRequest,
        withCacheOptions: [CachedStorageRequestTrigger]
    ) async -> AsyncThrowingStream<T?, Error> {
        AsyncThrowingStream<T?, Error> { continuation in
            if withCacheOptions.contains(.onAll) || withCacheOptions.isEmpty {
                getCacheValue(for: request, with: continuation)
                getFromPerform(request, with: continuation)
                return
            }
            if withCacheOptions.contains(.cache) {
                getCacheValue(for: request, with: continuation)
            }
            if withCacheOptions.contains(.onPerform) {
                getFromPerform(request, with: continuation)
            }
        }
    }

    // MARK: - Private methods
    
    private func getFromPerform<T: Decodable>(
        _ request: any StorageRequest,
        with continuation: AsyncThrowingStream<T?, Error>.Continuation
    ) {
        Task {
            do {
                let value: T? = try await performRequest(request)
                continuation.yield(value)
            } catch {
                continuation.yield(with: .failure(error))
            }
        }
    }

    private func getCacheValue<T: Decodable>(
        for request: any StorageRequest,
        with continuation: AsyncThrowingStream<T?, Error>.Continuation
    ) {
        Task {
            do {
                let key = try storageRequestKeyFactory.createKeyFor(request)
                let cache = try await cacheStorage.fetch(by: key.toHex())
                let decoded: T? = try decode(data: cache?.payload)
                guard let decoded = decoded else {
                    return
                }
                continuation.yield(decoded)
            } catch {
                continuation.yield(with: .failure(error))
            }
        }
    }

    private func decode<T: Decodable>(data: Data?) throws -> T? {
        guard let data = data else {
            return nil
        }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    private func save(
        data: Data?,
        for request: StorageRequest
    ) {
        Task {
            let key = try storageRequestKeyFactory.createKeyFor(request)
            let payload = try JSONEncoder().encode(data)
            let singleValueObject = SingleValueProviderObject(
                identifier: key.toHex(),
                payload: payload
            )
            try await cacheStorage.save(models: [singleValueObject])
        }
    }
}
