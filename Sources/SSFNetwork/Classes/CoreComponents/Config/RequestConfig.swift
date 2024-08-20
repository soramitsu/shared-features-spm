import Foundation

open class RequestConfig {
    public var baseURL: URL
    public var method: HTTPMethod
    public var endpoint: String?
    public var queryItems: [URLQueryItem]?
    public var headers: [HTTPHeader]?
    public var body: Data?
    public var timeout: TimeInterval?

    public var requestType: NetworkRequestType = .plain
    public var signingType: RequestSigningType = .none
    public var networkClientType: NetworkClientType = .plain
    public var decoderType: ResponseDecoderType = .codable(jsonDecoder: JSONDecoder())

    public init(
        baseURL: URL,
        method: HTTPMethod,
        endpoint: String?,
        queryItems: [URLQueryItem]? = nil,
        headers: [HTTPHeader]?,
        body: Data?,
        timeout: TimeInterval? = nil
    ) {
        self.baseURL = baseURL
        self.method = method
        self.endpoint = endpoint
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }

    open var cacheKey: String {
        var cacheKey = baseURL.absoluteString

        if let endpoint = endpoint {
            cacheKey = cacheKey.appending(endpoint)
        }

        if let queryItems = queryItems {
            let queryItemsString = queryItems.compactMap { "\($0.name)-\($0.value.or(""))" }
                .joined(separator: "-")
            cacheKey = cacheKey.appending(queryItemsString)
        }

        if let body = body, let json = try? JSONDecoder().decode(String.self, from: body) {
            cacheKey = cacheKey.appending(json)
        }

        return cacheKey
    }
}
