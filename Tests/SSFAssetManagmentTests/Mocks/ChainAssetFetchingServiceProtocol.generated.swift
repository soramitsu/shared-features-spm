// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAssetManagment
@testable import SSFModels

actor ChainAssetFetchingServiceProtocolMock: ChainAssetFetchingServiceProtocol {

    //MARK: - fetch

    var fetchFiltersSortsForceUpdateCallsCount = 0
    var fetchFiltersSortsForceUpdateCalled: Bool {
        return fetchFiltersSortsForceUpdateCallsCount > 0
    }
    var fetchFiltersSortsForceUpdateReceivedArguments: (filters: [AssetFilter], sorts: [AssetSort], forceUpdate: Bool)?
    var fetchFiltersSortsForceUpdateReceivedInvocations: [(filters: [AssetFilter], sorts: [AssetSort], forceUpdate: Bool)] = []
    var fetchFiltersSortsForceUpdateReturnValue: [ChainAsset]!
    var fetchFiltersSortsForceUpdateClosure: (([AssetFilter], [AssetSort], Bool) -> [ChainAsset])?

    func fetch(filters: [AssetFilter], sorts: [AssetSort], forceUpdate: Bool) -> [ChainAsset] {
        fetchFiltersSortsForceUpdateCallsCount += 1
        fetchFiltersSortsForceUpdateReceivedArguments = (filters: filters, sorts: sorts, forceUpdate: forceUpdate)
        fetchFiltersSortsForceUpdateReceivedInvocations.append((filters: filters, sorts: sorts, forceUpdate: forceUpdate))
        return fetchFiltersSortsForceUpdateClosure.map({ $0(filters, sorts, forceUpdate) }) ?? fetchFiltersSortsForceUpdateReturnValue
    }

}
