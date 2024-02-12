// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFXCM
@testable import SSFUtils
@testable import SSFNetwork
@testable import SSFModels
@testable import RobinHood
@testable import BigInt
@testable import SSFExtrinsicKit
@testable import SSFChainRegistry
@testable import SSFRuntimeCodingService
@testable import SSFSigner
@testable import SSFChainConnection
@testable import SSFStorageQueryKit

class XcmVersionFetchingMock: XcmVersionFetching {

    //MARK: - getVersion

    var getVersionForThrowableError: Error?
    var getVersionForCallsCount = 0
    var getVersionForCalled: Bool {
        return getVersionForCallsCount > 0
    }
    var getVersionForReceivedChainId: String?
    var getVersionForReceivedInvocations: [String] = []
    var getVersionForReturnValue: XcmCallFactoryVersion!
    var getVersionForClosure: ((String) throws -> XcmCallFactoryVersion)?

    func getVersion(for chainId: String) throws -> XcmCallFactoryVersion {
        if let error = getVersionForThrowableError {
            throw error
        }
        getVersionForCallsCount += 1
        getVersionForReceivedChainId = chainId
        getVersionForReceivedInvocations.append(chainId)
        return try getVersionForClosure.map({ try $0(chainId) }) ?? getVersionForReturnValue
    }

}
