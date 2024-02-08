import UIKit
@testable import SSFNetwork
@testable import RobinHood

class NetworkOperationFactoryProtocolMock<U: Decodable>: NetworkOperationFactoryProtocol {

    //MARK: - fetchData<T: Decodable>

    var fetchDataFromCallsCount = 0
    var fetchDataFromCalled: Bool {
        return fetchDataFromCallsCount > 0
    }
    var fetchDataFromReceivedUrl: URL?
    var fetchDataFromReceivedInvocations: [URL] = []
    var fetchDataFromReturnValue: BaseOperation<U>!
    var fetchDataFromClosure: ((URL) -> BaseOperation<U>)?

    func fetchData<T: Decodable>(from url: URL) -> BaseOperation<T> {
        fetchDataFromCallsCount += 1
        fetchDataFromReceivedUrl = url
        fetchDataFromReceivedInvocations.append(url)
        return fetchDataFromReturnValue as! BaseOperation<T>
    }
}

