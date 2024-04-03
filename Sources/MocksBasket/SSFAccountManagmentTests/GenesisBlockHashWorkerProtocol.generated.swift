// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import RobinHood
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils

public class GenesisBlockHashWorkerProtocolMock: GenesisBlockHashWorkerProtocol {
    public init() {}

    // MARK: - getGenesisHash

    public var getGenesisHashCallsCount = 0
    public var getGenesisHashCalled: Bool {
        getGenesisHashCallsCount > 0
    }

    public var getGenesisHashReturnValue: String?
    public var getGenesisHashClosure: (() -> String?)?

    public func getGenesisHash() -> String? {
        getGenesisHashCallsCount += 1
        return getGenesisHashClosure.map { $0() } ?? getGenesisHashReturnValue
    }
}
