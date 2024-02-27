import Foundation
import SSFUtils
import SSFRuntimeCodingService
import SSFSingleValueCache
import RobinHood
import SSFModels

public protocol StorageRequestPerformer {
    func performSingle<T: Decodable>(
        _ request: StorageRequest
    ) async throws -> T?
    
    func performSingle<T: Decodable>(
        _ request: StorageRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<T?, Error>
    
    func performMultiple<T: Decodable>(
        _ request: MultipleRequest
    ) async throws -> [T?]
    
    func performMultiple<T: Decodable>(
        _ request: MultipleRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<[T?], Error>
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
    
    public func performSingle<T: Decodable>(_ request: StorageRequest) async throws -> T? {
        let worker = StorageRequestWorkerBuilderDefault<T>().buildWorker(
            runtimeService: runtimeService,
            connection: connection,
            storageRequestFactory: storageRequestFactory,
            type: request.parametersType.workerType
        )

        let valueExtractor = SingleStorageResponseValueExtractor()
        let response: [StorageResponse<T>] = try await worker.perform(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        let value = try valueExtractor.extractValue(storageResponse: response)
        save(
            response: response,
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        return value
    }
    
    public func performSingle<T: Decodable>(
        _ request: StorageRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<T?, Error> {
        AsyncThrowingStream<T?, Error> { continuation in
            Task {
                if withCacheOptions == .onAll || withCacheOptions.isEmpty {
                    try await getCacheSingleValue(for: request, with: continuation)
                    let value: T? = try await performSingle(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
                if withCacheOptions.contains(.onCache) {
                    try await getCacheSingleValue(for: request, with: continuation)
                    continuation.finish()
                    return
                }
                if withCacheOptions.contains(.onPerform) {
                    let value: T? = try await performSingle(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
            }
        }
    }
    
    public func performMultiple<T: Decodable>(
        _ request: MultipleRequest
    ) async throws -> [T?] {
        let worker = StorageRequestWorkerBuilderDefault<T>().buildWorker(
            runtimeService: runtimeService,
            connection: connection,
            storageRequestFactory: storageRequestFactory,
            type: request.parametersType.workerType
        )
        
        let valueExtractor = MultipleSingleStorageResponseValueExtractor()
        let response: [StorageResponse<T>] = try await worker.perform(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        let values = try valueExtractor.extractValue(storageResponse: response)
        save(
            response: response,
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        
        return values
    }
    
    public func performMultiple<T: Decodable>(
        _ request: MultipleRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<[T?], Error> {
        AsyncThrowingStream<[T?], Error> { continuation in
            Task {
                if withCacheOptions == .onAll || withCacheOptions.isEmpty {
                    try await getCacheMultipleValue(for: request, with: continuation)
                    let value: [T?] = try await performMultiple(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
                if withCacheOptions.contains(.onCache) {
                    try await getCacheMultipleValue(for: request, with: continuation)
                    continuation.finish()
                    return
                }
                if withCacheOptions.contains(.onPerform) {
                    let value: [T?] = try await performMultiple(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
            }
        }
    }

    // MARK: - Private methods

    private func getCacheSingleValue<T: Decodable>(
        for request: StorageRequest,
        with continuation: AsyncThrowingStream<T?, Error>.Continuation
    ) async throws {
        let cache: [T?]? = try await getCache(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        guard let decoded = cache?.first else {
            return
        }
        continuation.yield(decoded)
    }
    
    private func getCacheMultipleValue<T: Decodable>(
        for request: MultipleRequest,
        with continuation: AsyncThrowingStream<[T?], Error>.Continuation
    ) async throws {
        let cache: [T?]? = try await getCache(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        guard let cache = cache else {
            return
        }
        continuation.yield(cache)
    }
    
    private func getCache<T: Decodable>(
        params: StorageRequestWorkerType,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [T?]? {
        let key = try storageRequestKeyFactory.createKeyFor(
            params: params,
            storagePath: storagePath
        )
        let cache = try await cacheStorage.fetch(by: key.toHex())
        guard let payload = cache?.payload else {
            return nil
        }
        let codingFactory = try await runtimeService.fetchCoderFactory()
        let decoded: [T?] = try decode(
            payload: payload,
            codingFactory: codingFactory,
            path: storagePath
        )
        return decoded
    }

    private func decode<T: Decodable>(
        payload: Data,
        codingFactory: RuntimeCoderFactoryProtocol,
        path: any StorageCodingPathProtocol
    ) throws -> [T?] {
        let data = try JSONDecoder().decode([Data].self, from: payload)
        let decoder = StorageFallbackDecodingListWorker<T>(
            codingFactory: codingFactory,
            path: path,
            dataList: data
        )
        return try decoder.performDecoding()
    }
    
    private func save<T: Decodable>(
        response: [StorageResponse<T>],
        params: StorageRequestWorkerType,
        storagePath: any StorageCodingPathProtocol
    ) {
        Task {
            let key = try storageRequestKeyFactory.createKeyFor(
                params: params,
                storagePath: storagePath
            )
            let payload = response.map { $0.data }.compactMap { $0 }
            let singleValueObject = SingleValueProviderObject(
                identifier: key.toHex(),
                payload: try JSONEncoder().encode(payload)
            )
            try await cacheStorage.save(models: [singleValueObject])
        }
    }
}
