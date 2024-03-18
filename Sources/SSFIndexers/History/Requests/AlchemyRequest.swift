import Foundation
import SSFNetwork
import SSFUtils

final class AlchemyRequest: RequestConfig {
    private enum Constants {
        static let httpHeaders = [
            HTTPHeader(field: "accept", value: "application/json"),
            HTTPHeader(field: "content-type", value: "application/json")
        ]
    }
    
    init(
        baseURL: URL,
        request: AlchemyHistoryRequest
    ) throws {
        let body = JSONRPCInfo(
            identifier: 1,
            jsonrpc: "2.0",
            method: AlchemyEndpoint.getAssetTransfers.rawValue,
            params: [request]
        )
        let paramsEncoded = try JSONEncoder().encode(body)
        super.init(
            baseURL: baseURL,
            method: .post,
            endpoint: nil,
            headers: Constants.httpHeaders,
            body: paramsEncoded
        )
    }
}
