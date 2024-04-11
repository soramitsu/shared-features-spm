import Foundation
import RobinHood
import SSFModels
import SSFRuntimeCodingService
import SSFSingleValueCache
import SSFUtils
import SSFChainRegistry

public protocol StorageRequestPerformer {
    func performSingle<T: Decodable>(
        _ request: StorageRequest
    ) async throws -> T?

    func performSingle<T: Decodable>(
        _ request: StorageRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<T?, Error>

    func performMultiple<K: Decodable & ScaleCodable & Hashable, T: Decodable>(
        _ request: MultipleRequest
    ) async throws -> [K:T]?

    func performMultiple<K: Decodable & ScaleCodable & Hashable, T: Decodable>(
        _ request: MultipleRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<[K:T]?, Error>
    
    func performPrefix<T, K>(
        _ request: PrefixRequest
    ) async throws -> [K: T]? where T: Decodable, K: Decodable & ScaleCodable, K: Hashable
}

public final class StorageRequestPerformerDefault: StorageRequestPerformer {
    private let chainRegistry: ChainRegistryProtocol
    private let chain: ChainModel
    private var runtimeService: RuntimeCodingServiceProtocol?
    
    private lazy var storageRequestFactory: AsyncStorageRequestFactory =
        AsyncStorageRequestDefault()

    private lazy var cacheStorage: AsyncSingleValueRepository = {
        SingleValueCacheRepositoryFactoryDefault().createAsyncSingleValueCacheRepository()
    }()

    public init(chainRegistry: ChainRegistryProtocol, chain: ChainModel) {
        self.chainRegistry = chainRegistry
        self.chain = chain
    }

    // MARK: - StorageRequestPerformer

    public func performSingle<T: Decodable>(_ request: StorageRequest) async throws -> T? {
        let runtimeService = try await chainRegistry.getRuntimeProvider(
            chainId: chain.chainId,
            usedRuntimePaths: [:],
            runtimeItem: nil
        )
        
        let connection = try chainRegistry.getSubstrateConnection(for: chain)
        
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

    public func performMultiple<K, T>(
        _ request: MultipleRequest
    ) async throws -> [K:T]? where T: Decodable, K: Decodable & ScaleCodable, K: Hashable {
        let runtimeService = try await chainRegistry.getRuntimeProvider(
            chainId: chain.chainId,
            usedRuntimePaths: [:],
            runtimeItem: nil
        )
        
        let connection = try chainRegistry.getSubstrateConnection(for: chain)
        
        let worker = StorageRequestWorkerBuilderDefault<T>().buildWorker(
            runtimeService: runtimeService,
            connection: connection,
            storageRequestFactory: storageRequestFactory,
            type: request.parametersType.workerType
        )

        let valueExtractor = MultipleSingleStorageResponseValueExtractor(runtimeService: runtimeService)
        let response: [StorageResponse<T>] = try await worker.perform(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        let values: [K:T]? = try await valueExtractor.extractValue(request: request, storageResponse: response)
        save(
            response: response,
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )

        return values
    }

    public func performMultiple<K: Decodable & ScaleCodable & Hashable, T: Decodable>(
        _ request: MultipleRequest,
        withCacheOptions: CachedStorageRequestTrigger
    ) async -> AsyncThrowingStream<[K:T]?, Error>  {
        AsyncThrowingStream<[K:T]?, Error> { continuation in
            Task {
                if withCacheOptions == .onAll || withCacheOptions.isEmpty {
                    try await getCacheMultipleValue(for: request, with: continuation)
                    let value: [K:T]? = try await performMultiple(request)
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
                    let value: [K:T]? = try await performMultiple(request)
                    continuation.yield(value)
                    continuation.finish()
                    return
                }
            }
        }
    }
    
    public func performPrefix<T, K>(
        _ request: PrefixRequest
    ) async throws -> [K: T]? where T: Decodable, K: Decodable & ScaleCodable, K: Hashable {
        let runtimeService = try await chainRegistry.getRuntimeProvider(
            chainId: chain.chainId,
            usedRuntimePaths: [:],
            runtimeItem: nil
        )
        
        let connection = try chainRegistry.getSubstrateConnection(for: chain)
        
        let worker = StorageRequestWorkerBuilderDefault<T>().buildWorker(
            runtimeService: runtimeService,
            connection: connection,
            storageRequestFactory: storageRequestFactory,
            type: request.parametersType.workerType
        )

        let valueExtractor = PrefixStorageResponseValueExtractor(runtimeService: runtimeService)
        let response: [StorageResponse<T>] = try await worker.perform(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        let values: [K: T]? = try await valueExtractor.extractValue(request: request, storageResponse: response)
        return values
    }

    // MARK: - Private methods

    private func getCacheSingleValue<T: Decodable>(
        for request: StorageRequest,
        with continuation: AsyncThrowingStream<T?, Error>.Continuation
    ) async throws {
        let cache: [Data:T]? = try await getCache(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        guard let decoded = cache?.first?.value else {
            return
        }
        continuation.yield(decoded)
    }

    private func getCacheMultipleValue<K, T>(
        for request: MultipleRequest,
        with continuation: AsyncThrowingStream<[K:T]?, Error>.Continuation
    ) async throws where T: Decodable, K: Decodable & ScaleCodable, K: Hashable {
        guard let runtimeService else {
            return
        }
        let keyExtractor = StorageKeyDataExtractor(runtimeService: runtimeService)

        let cache: [Data:T]? = try await getCache(
            params: request.parametersType.workerType,
            storagePath: request.storagePath
        )
        guard let cache = cache else {
            return
        }
        
        let resultArray: [[K:T]] = try await cache.asyncCompactMap {
            let key: K = try await keyExtractor.extractKey(storageKey: $0.key, storagePath: request.storagePath, type: request.keyType)
            return [key: $0.value]
        }
        let result = Dictionary(resultArray.flatMap { $0 }, uniquingKeysWith: { _, last in last })
        continuation.yield(result)
    }
    
    private func getCache<T: Decodable>(
        params: StorageRequestWorkerType,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [Data:T]? {
        let runtimeService = try await chainRegistry.getRuntimeProvider(
            chainId: chain.chainId,
            usedRuntimePaths: [:],
            runtimeItem: nil
        )
        let codingFactory = try await runtimeService.fetchCoderFactory()
        let keysEncoder = StorageRequestKeyEncodingWorkerFactoryDefault().buildFactory(
            storageCodingPath: storagePath,
            workerType: params,
            codingFactory: codingFactory,
            storageKeyFactory: StorageKeyFactory()
        )
        let keys = try keysEncoder.performEncoding()
        let cache = try await cacheStorage.fetch(by: keys.compactMap { $0.toHex() }, options: RepositoryFetchOptions())
        

        let caches = try cache.compactMap {
            let item: [Data:T]? = try decode(
                object: $0,
                codingFactory: codingFactory,
                path: storagePath
            )
            return item
        }
    
        return Dictionary(caches.flatMap { $0 }, uniquingKeysWith: { _, last in last })
    }

    private func decode<T: Decodable>(
        object: SingleValueProviderObject,
        codingFactory: RuntimeCoderFactoryProtocol,
        path: any StorageCodingPathProtocol
    ) throws -> [Data:T]? {
        let data = try JSONDecoder().decode(Data.self, from: object.payload)
        let decoder = StorageFallbackDecodingListWorker<T>(
            codingFactory: codingFactory,
            path: path,
            dataList: [data]
        )
        guard let value = try decoder.performDecoding().compactMap({ $0 }).first else {
            return nil
        }
        
        let key = Data(hex: object.identifier)
        
        return [key: value]
    }

    private func save<T: Decodable>(
        response: [StorageResponse<T>],
        params: StorageRequestWorkerType,
        storagePath: any StorageCodingPathProtocol
    ) {
        Task {
            let objects: [SingleValueProviderObject] = response.compactMap {
                guard let data = $0.data else {
                    return nil
                }
                
                return SingleValueProviderObject(identifier: $0.key.toHex(), payload: data)
            }
            
            try await cacheStorage.save(models: objects)
        }
    }
}
