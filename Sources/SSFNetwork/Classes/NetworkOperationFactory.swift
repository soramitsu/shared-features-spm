import Foundation
import RobinHood

public protocol NetworkOperationFactoryProtocol {
    func fetchData<T: Decodable>(from url: URL) -> BaseOperation<T>
}

public final class NetworkOperationFactory: NetworkOperationFactoryProtocol {
    public init() {}
    public func fetchData<T: Decodable>(from url: URL) -> BaseOperation<T> {
        let requestFactory = BlockNetworkRequestFactory {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.httpMethod = HttpMethod.get.rawValue
            return request
        }

        let resultFactory = AnyNetworkResultFactory<T> { data in
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
        }

        let operation = NetworkOperation(requestFactory: requestFactory, resultFactory: resultFactory)

        return operation
    }
}
