import Foundation
import RobinHood
import SSFLogger
import SSFSingleValueCache
import SSFUtils

public protocol NetworkWorker {
    func fetchCached<T: Decodable>(with config: RequestConfig) async throws -> T?
    func performRequest<T>(with config: RequestConfig) async throws -> T

    func performRequest<T: Decodable>(
        with config: RequestConfig,
        withCacheOptions: CachedNetworkRequestTrigger
    ) async -> AsyncThrowingStream<CachedNetworkResponse<T>, Error>
}

public final class NetworkWorkerImpl: NetworkWorker {
    public init() {}

    private lazy var cacheStorage: AsyncSingleValueRepository =
        SingleValueCacheRepositoryFactoryDefault().createAsyncSingleValueCacheRepository()

    public func fetchCached<T: Decodable>(with config: RequestConfig) async throws -> T? {
        let cached: T? = try await getCache(config: config)
        return cached
    }

    public func performRequest<T>(with config: RequestConfig) async throws -> T {
        let requestConfigurator = try BaseRequestConfiguratorFactory().buildRequestConfigurator(
            with: config.requestType,
            baseURL: config.baseURL
        )
        let requestSigner = try BaseRequestSignerFactory()
            .buildRequestSigner(with: config.signingType)
        let networkClient = BaseNetworkClientFactory()
            .buildNetworkClient(with: config.networkClientType)
        let responseDecoder = BaseResponseDecoderFactory()
            .buildResponseDecoder(with: config.decoderType)

        var request = try requestConfigurator.buildRequest(with: config)
        try requestSigner?.sign(request: &request, config: config)
        let response = try await networkClient.perform(request: request)

        save(
            response: response,
            config: config
        )

        let decoded: T = try responseDecoder.decode(data: response)
        return decoded
    }

    public func performRequest<T: Decodable>(
        with config: RequestConfig,
        withCacheOptions: CachedNetworkRequestTrigger
    ) async -> AsyncThrowingStream<CachedNetworkResponse<T>, Error> {
        AsyncThrowingStream<CachedNetworkResponse<T>, Error> { continuation in
            Task {
                if withCacheOptions == .onAll || withCacheOptions.isEmpty {
                    let cached: T? = try? await getCache(config: config)
                    if let unwrapped = cached {
                        let response = CachedNetworkResponse(value: unwrapped, type: .cache)
                        continuation.yield(response)
                    }

                    do {
                        let value: T? = try await performRequest(with: config)
                        let response = CachedNetworkResponse(value: value, type: .remote)
                        continuation.yield(response)
                        continuation.finish()
                    } catch {
                        continuation.yield(with: .failure(error))
                    }
                    return
                }
                if withCacheOptions.contains(.onCache) {
                    let cached: T? = try await getCache(config: config)
                    if let cached = cached {
                        let response = CachedNetworkResponse(value: cached, type: .cache)
                        continuation.yield(response)
                    }
                    return
                }
                if withCacheOptions.contains(.onPerform) {
                    let value: T? = try await performRequest(with: config)
                    let response = CachedNetworkResponse(value: value, type: .remote)
                    continuation.yield(response)
                    continuation.finish()
                    return
                }
            }
        }
    }

    private func getCache<T: Decodable>(
        config: RequestConfig
    ) async throws -> T? {
        guard let dictKey = config.cacheKey.data(using: .utf8) else {
            throw NetworkingError.unableToParseResponse
        }

        let cache = try await cacheStorage.fetch(
            by: [config.cacheKey],
            options: RepositoryFetchOptions()
        )

        let caches = cache.compactMap {
            let item: [Data: T]? = try? decode(
                object: $0,
                request: config
            )
            return item
        }

        let dict = Dictionary(caches.flatMap { $0 }, uniquingKeysWith: { _, last in last })
        return dict[dictKey]
    }

    private func decode<T: Decodable>(
        object: SingleValueProviderObject,
        request: RequestConfig
    ) throws -> [Data: T]? {
        guard let key = object.identifier.data(using: .utf8) else {
            throw NetworkingError.unableToParseResponse
        }

        var decoder: JSONDecoder
        switch request.decoderType {
        case let .codable(jsonDecoder):
            decoder = jsonDecoder
        default:
            decoder = JSONDecoder()
        }

        let value = try decoder.decode(T.self, from: object.payload)
        return [key: value]
    }

    private func save(
        response: Data,
        config: RequestConfig
    ) {
        Task {
            let object = SingleValueProviderObject(identifier: config.cacheKey, payload: response)
            await cacheStorage.save(models: [object])
        }
    }
}
