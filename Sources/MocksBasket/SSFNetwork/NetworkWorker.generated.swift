// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFNetwork
@testable import RobinHood

public class NetworkWorkerMock<T: Decodable>: NetworkWorker {
public init() {}

    //MARK: - performRequest<T: Decodable>

    public var performRequestWithThrowableError: Error?
    public var performRequestWithCallsCount = 0
    public var performRequestWithCalled: Bool {
        return performRequestWithCallsCount > 0
    }
    public var performRequestWithReceivedConfig: RequestConfig?
    public var performRequestWithReceivedInvocations: [RequestConfig] = []
    public var performRequestWithReturnValue: T!
    public var performRequestWithClosure: ((RequestConfig) throws -> T)?

    public func performRequest<T: Decodable>(with config: RequestConfig) throws -> T {
        if let error = performRequestWithThrowableError {
            throw error
        }
        performRequestWithCallsCount += 1
        performRequestWithReceivedConfig = config
        performRequestWithReceivedInvocations.append(config)
        return performRequestWithReturnValue as! T
    }

}
