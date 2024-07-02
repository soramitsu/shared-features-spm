import Foundation

final class RESTNetworkClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    private func processDataResponse(
        urlRequest _: URLRequest,
        data: Data,
        response: URLResponse
    ) throws -> Data {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkingError.init(status: .unknown)
        }
        guard 200 ..< 299 ~= statusCode else {
            throw NetworkingError.init(errorCode: statusCode)
        }

        return data
    }
}

extension RESTNetworkClient: NetworkClient {
    func perform(request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        return try processDataResponse(urlRequest: request, data: data, response: response)
    }
}
