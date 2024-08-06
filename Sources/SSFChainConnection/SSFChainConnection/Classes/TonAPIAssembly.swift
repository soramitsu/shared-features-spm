import Foundation
import StreamURLSessionTransport
import TonAPI
import OpenAPIRuntime
import HTTPTypes

public final class TonAPIAssembly {
    public let tonAPIURL: URL
    private let token: String
    
    public init(
        tonAPIURL: URL,
        token: String
    ) {
        self.tonAPIURL = tonAPIURL
        self.token = token
    }
    
    private var _tonAPIClient: TonAPI.Client?
    public func tonAPIClient() -> TonAPI.Client {
        if let tonAPIClient = _tonAPIClient {
            return tonAPIClient
        }
        let tonAPIClient = TonAPI.Client(
            serverURL: tonAPIURL,
            transport: transport,
            middlewares: [authTokenProvider]
        )
        _tonAPIClient = tonAPIClient
        return tonAPIClient
    }
    
    // MARK: - Private
    
    private lazy var authTokenProvider: AuthTokenProvider = {
        AuthTokenProvider(token: token)
    }()
    
    private lazy var transport: StreamURLSessionTransport = {
        StreamURLSessionTransport(urlSessionConfiguration: urlSessionConfiguration)
    }()
    
    private var urlSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        return configuration
    }
}


final class AuthTokenProvider: ClientMiddleware {
    private let token: String
    init(token: String) {
        self.token = token
    }
    
    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL)
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var mutableRequest = request
        mutableRequest
            .headerFields
            .append(
                .init(
                    name: .authorization,
                    value: "Bearer \(token)"
                )
            )
        return try await next(mutableRequest, body, baseURL)
    }
}
