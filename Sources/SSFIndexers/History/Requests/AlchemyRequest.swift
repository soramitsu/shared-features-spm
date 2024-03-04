import Foundation
import SSFNetwork

final class AlchemyRequest: RequestConfig {
    private enum Constants {
        static let httpHeaders = [
            HTTPHeader(field: "accept", value: "application/json"),
            HTTPHeader(field: "content-type", value: "application/json")
        ]
    }

    init(baseURL: URL, body: Data?) {
        super.init(
            baseURL: baseURL,
            method: .post,
            endpoint: nil,
            headers: Constants.httpHeaders,
            body: body
        )
    }
}
