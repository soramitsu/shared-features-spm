import Foundation
import SSFModels
import RobinHood

public class GraphQLRequest: RequestConfig {
    public init(
        baseURL: URL,
        query: String
    ) throws {
        let defaultHeaders = [
            HTTPHeader(
                field: HttpHeaderKey.contentType.rawValue,
                value: HttpContentType.json.rawValue
            )
        ]

        let info = JSON.dictionaryValue(["query": JSON.stringValue(query)])
        let data = try JSONEncoder().encode(info)

        super.init(
            baseURL: baseURL,
            method: .post,
            endpoint: nil,
            headers: defaultHeaders,
            body: data
        )
    }
    
    override var cacheKey: String {
        guard
            let body,
            let json = try? JSONDecoder().decode(JSON.self, from: body),
            let key = json.dictValue?["query"]?.stringValue
        else {
            return super.cacheKey
        }
        
        return key
    }
}
