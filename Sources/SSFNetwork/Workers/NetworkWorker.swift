import Foundation

public final class NetworkWorker {
    public init() {}

    public func performRequest<T>(
        with config: RequestConfig
    ) async throws -> T {
        let requestConfiguratorFactory = BaseRequestConfiguratorFactory()
        let requestConfigurator = try requestConfiguratorFactory.buildRequestConfigurator(
            with: config.requestType,
            baseURL: config.baseURL
        )
        let requestSigner = try BaseRequestSignerFactory().buildRequestSigner(with: config.signingType)
        let networkClient = BaseNetworkClientFactory().buildNetworkClient(with: config.networkClientType)
        let responseDecoder = BaseResponseDecoderFactory().buildResponseDecoder(with: config.decoderType)

        var request = try requestConfigurator.buildRequest(with: config)
        try requestSigner?.sign(request: &request, config: config)
        let response = try await networkClient.perform(request: request)

        let decoded: T = try responseDecoder.decode(data: response)
        return decoded
    }
}
