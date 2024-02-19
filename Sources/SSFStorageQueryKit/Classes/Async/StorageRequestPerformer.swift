import Foundation
import SSFUtils
import SSFRuntimeCodingService
import SSFSingleValueCache
import RobinHood
import SSFModels

public protocol StorageRequestPerformer {
    func performRequest<T: Decodable>(
        _ request: any StorageRequest
    ) async throws -> T?
    
    func performRequest<T: Decodable>(
        _ request: any StorageRequest,
        withCacheOptions: CachedStorageRequestTrigger
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

        let valueExtractor = SingleStorageResponseValueExtractor()
        let response: [StorageResponse<T>] = try await worker.perform(request: request)
        let value = try valueExtractor.extractValue(storageResponse: response)
        if let data = response.first?.data {
            save(data: data, for: request)
        }

        return value
    }
    
    public func performRequest<T: Decodable>(
        _ request: any StorageRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<T?, Error> {
        AsyncThrowingStream<T?, Error> { continuation in
            Task {
                if withCacheOptions == .onAll || withCacheOptions.isEmpty {
                    try await getCacheValue(for: request, with: continuation)
                    let value: T? = try await performRequest(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
                if withCacheOptions.contains(.onCache) {
                    try await getCacheValue(for: request, with: continuation)
                    continuation.finish()
                    return
                }
                if withCacheOptions.contains(.onPerform) {
                    let value: T? = try await performRequest(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
            }
        }
    }

    // MARK: - Private methods

    private func getCacheValue<T: Decodable>(
        for request: any StorageRequest,
        with continuation: AsyncThrowingStream<T?, Error>.Continuation
    ) async throws {
        let key = try storageRequestKeyFactory.createKeyFor(request)
        let cache = try await cacheStorage.fetch(by: key.toHex())
        let codingFactory = try await runtimeService.fetchCoderFactory()
        let decoded: T? = try decode(
            data: cache?.payload,
            codingFactory: codingFactory,
            path: request.storagePath
        )
        guard let decoded = decoded else {
            return
        }
        continuation.yield(decoded)
    }

    private func decode<T: Decodable>(
        data: Data?,
        codingFactory: RuntimeCoderFactoryProtocol,
        path: any StorageCodingPathProtocol
    ) throws -> T? {
        guard let data = data else {
            return nil
        }
        let decoder = StorageFallbackDecodingListWorker<T>(
            codingFactory: codingFactory,
            path: path,
            dataList: [data]
        )
        guard let decoded = try decoder.performDecoding().first else {
            return nil
        }
        return decoded
    }
    
    private func save(
        data: Data,
        for request: StorageRequest
    ) {
        Task {
            let key = try storageRequestKeyFactory.createKeyFor(request)
            let singleValueObject = SingleValueProviderObject(
                identifier: key.toHex(),
                payload: data
            )
            try await cacheStorage.save(models: [singleValueObject])
        }
    }
}
