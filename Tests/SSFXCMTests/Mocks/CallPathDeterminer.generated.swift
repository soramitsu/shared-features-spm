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

class CallPathDeterminerMock: CallPathDeterminer {

    //MARK: - determineCallPath

    var determineCallPathFromDestThrowableError: Error?
    var determineCallPathFromDestCallsCount = 0
    var determineCallPathFromDestCalled: Bool {
        return determineCallPathFromDestCallsCount > 0
    }
    var determineCallPathFromDestReceivedArguments: (from: XcmChainType, dest: XcmChainType)?
    var determineCallPathFromDestReceivedInvocations: [(from: XcmChainType, dest: XcmChainType)] = []
    var determineCallPathFromDestReturnValue: XcmCallPath!
    var determineCallPathFromDestClosure: ((XcmChainType, XcmChainType) throws -> XcmCallPath)?

    func determineCallPath(from: XcmChainType, dest: XcmChainType) throws -> XcmCallPath {
        if let error = determineCallPathFromDestThrowableError {
            throw error
        }
        determineCallPathFromDestCallsCount += 1
        determineCallPathFromDestReceivedArguments = (from: from, dest: dest)
        determineCallPathFromDestReceivedInvocations.append((from: from, dest: dest))
        return try determineCallPathFromDestClosure.map({ try $0(from, dest) }) ?? determineCallPathFromDestReturnValue
    }

}
