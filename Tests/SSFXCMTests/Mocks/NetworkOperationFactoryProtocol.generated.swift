// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFNetwork
@testable import RobinHood

class NetworkOperationFactoryProtocolMock<T: Decodable>: NetworkOperationFactoryProtocol {

    //MARK: - fetchData<T: Decodable>

    var fetchDataFromCallsCount = 0
    var fetchDataFromCalled: Bool {
        return fetchDataFromCallsCount > 0
    }
    var fetchDataFromReceivedUrl: URL?
    var fetchDataFromReceivedInvocations: [URL] = []
    var fetchDataFromReturnValue: BaseOperation<T>!
    var fetchDataFromClosure: ((URL) -> BaseOperation<T>)?

    func fetchData<T: Decodable>(from url: URL) -> BaseOperation<T> {
        fetchDataFromCallsCount += 1
        fetchDataFromReceivedUrl = url
        fetchDataFromReceivedInvocations.append(url)
        return fetchDataFromClosure.map({ $0(url) }) ?? fetchDataFromReturnValue
    }
}
