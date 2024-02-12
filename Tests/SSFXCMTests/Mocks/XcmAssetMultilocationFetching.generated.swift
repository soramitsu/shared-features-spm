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

class XcmAssetMultilocationFetchingMock: XcmAssetMultilocationFetching {

    //MARK: - versionedMultilocation

    var versionedMultilocationOriginAssetIdDestChainIdThrowableError: Error?
    var versionedMultilocationOriginAssetIdDestChainIdCallsCount = 0
    var versionedMultilocationOriginAssetIdDestChainIdCalled: Bool {
        return versionedMultilocationOriginAssetIdDestChainIdCallsCount > 0
    }
    var versionedMultilocationOriginAssetIdDestChainIdReceivedArguments: (originAssetId: String, destChainId: ChainModel.Id)?
    var versionedMultilocationOriginAssetIdDestChainIdReceivedInvocations: [(originAssetId: String, destChainId: ChainModel.Id)] = []
    var versionedMultilocationOriginAssetIdDestChainIdReturnValue: AssetMultilocation!
    var versionedMultilocationOriginAssetIdDestChainIdClosure: ((String, ChainModel.Id) throws -> AssetMultilocation)?

    func versionedMultilocation(originAssetId: String, destChainId: ChainModel.Id) throws -> AssetMultilocation {
        if let error = versionedMultilocationOriginAssetIdDestChainIdThrowableError {
            throw error
        }
        versionedMultilocationOriginAssetIdDestChainIdCallsCount += 1
        versionedMultilocationOriginAssetIdDestChainIdReceivedArguments = (originAssetId: originAssetId, destChainId: destChainId)
        versionedMultilocationOriginAssetIdDestChainIdReceivedInvocations.append((originAssetId: originAssetId, destChainId: destChainId))
        return try versionedMultilocationOriginAssetIdDestChainIdClosure.map({ try $0(originAssetId, destChainId) }) ?? versionedMultilocationOriginAssetIdDestChainIdReturnValue
    }

}
