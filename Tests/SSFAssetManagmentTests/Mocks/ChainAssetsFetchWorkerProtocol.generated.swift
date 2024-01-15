// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAssetManagment
@testable import SSFModels

class ChainAssetsFetchWorkerProtocolMock: ChainAssetsFetchWorkerProtocol {

    //MARK: - getChainAssetsModels

    var getChainAssetsModelsCallsCount = 0
    var getChainAssetsModelsCalled: Bool {
        return getChainAssetsModelsCallsCount > 0
    }
    var getChainAssetsModelsReturnValue: [ChainAsset]!
    var getChainAssetsModelsClosure: (() -> [ChainAsset])?

    func getChainAssetsModels() -> [ChainAsset] {
        getChainAssetsModelsCallsCount += 1
        return getChainAssetsModelsClosure.map({ $0() }) ?? getChainAssetsModelsReturnValue
    }

}
