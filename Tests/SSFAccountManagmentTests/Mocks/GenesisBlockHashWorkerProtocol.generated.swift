// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class GenesisBlockHashWorkerProtocolMock: GenesisBlockHashWorkerProtocol {

    //MARK: - getGenesisHash

    var getGenesisHashCallsCount = 0
    var getGenesisHashCalled: Bool {
        return getGenesisHashCallsCount > 0
    }
    var getGenesisHashReturnValue: String?
    var getGenesisHashClosure: (() -> String?)?

    func getGenesisHash() -> String? {
        getGenesisHashCallsCount += 1
        return getGenesisHashClosure.map({ $0() }) ?? getGenesisHashReturnValue
    }

}
