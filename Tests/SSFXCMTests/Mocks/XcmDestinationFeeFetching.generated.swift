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

class XcmDestinationFeeFetchingMock: XcmDestinationFeeFetching {

    //MARK: - estimateFee

    var estimateFeeDestinationChainIdTokenCallsCount = 0
    var estimateFeeDestinationChainIdTokenCalled: Bool {
        return estimateFeeDestinationChainIdTokenCallsCount > 0
    }
    var estimateFeeDestinationChainIdTokenReceivedArguments: (destinationChainId: String, token: String)?
    var estimateFeeDestinationChainIdTokenReceivedInvocations: [(destinationChainId: String, token: String)] = []
    var estimateFeeDestinationChainIdTokenReturnValue: Result<DestXcmFee, Error>!
    var estimateFeeDestinationChainIdTokenClosure: ((String, String) -> Result<DestXcmFee, Error>)?

    func estimateFee(destinationChainId: String, token: String) -> Result<DestXcmFee, Error> {
        estimateFeeDestinationChainIdTokenCallsCount += 1
        estimateFeeDestinationChainIdTokenReceivedArguments = (destinationChainId: destinationChainId, token: token)
        estimateFeeDestinationChainIdTokenReceivedInvocations.append((destinationChainId: destinationChainId, token: token))
        return estimateFeeDestinationChainIdTokenClosure.map({ $0(destinationChainId, token) }) ?? estimateFeeDestinationChainIdTokenReturnValue
    }

    //MARK: - estimateWeight

    var estimateWeightForThrowableError: Error?
    var estimateWeightForCallsCount = 0
    var estimateWeightForCalled: Bool {
        return estimateWeightForCallsCount > 0
    }
    var estimateWeightForReceivedChainId: String?
    var estimateWeightForReceivedInvocations: [String] = []
    var estimateWeightForReturnValue: BigUInt!
    var estimateWeightForClosure: ((String) throws -> BigUInt)?

    func estimateWeight(for chainId: String) throws -> BigUInt {
        if let error = estimateWeightForThrowableError {
            throw error
        }
        estimateWeightForCallsCount += 1
        estimateWeightForReceivedChainId = chainId
        estimateWeightForReceivedInvocations.append(chainId)
        return try estimateWeightForClosure.map({ try $0(chainId) }) ?? estimateWeightForReturnValue
    }

}
