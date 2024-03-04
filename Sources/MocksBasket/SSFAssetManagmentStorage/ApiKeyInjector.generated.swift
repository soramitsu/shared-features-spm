// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAssetManagmentStorage
@testable import SSFModels

public class ApiKeyInjectorMock: ApiKeyInjector {
public init() {}

    //MARK: - getBlockExplorerKey

    public var getBlockExplorerKeyForChainIdCallsCount = 0
    public var getBlockExplorerKeyForChainIdCalled: Bool {
        return getBlockExplorerKeyForChainIdCallsCount > 0
    }
    public var getBlockExplorerKeyForChainIdReceivedArguments: (type: BlockExplorerType, chainId: ChainModel.Id)?
    public var getBlockExplorerKeyForChainIdReceivedInvocations: [(type: BlockExplorerType, chainId: ChainModel.Id)] = []
    public var getBlockExplorerKeyForChainIdReturnValue: String?
    public var getBlockExplorerKeyForChainIdClosure: ((BlockExplorerType, ChainModel.Id) -> String?)?

    public func getBlockExplorerKey(for type: BlockExplorerType, chainId: ChainModel.Id) -> String? {
        getBlockExplorerKeyForChainIdCallsCount += 1
        getBlockExplorerKeyForChainIdReceivedArguments = (type: type, chainId: chainId)
        getBlockExplorerKeyForChainIdReceivedInvocations.append((type: type, chainId: chainId))
        return getBlockExplorerKeyForChainIdClosure.map({ $0(type, chainId) }) ?? getBlockExplorerKeyForChainIdReturnValue
    }

    //MARK: - getNodeApiKey

    public var getNodeApiKeyForApiKeyNameCallsCount = 0
    public var getNodeApiKeyForApiKeyNameCalled: Bool {
        return getNodeApiKeyForApiKeyNameCallsCount > 0
    }
    public var getNodeApiKeyForApiKeyNameReceivedArguments: (chainId: String, apiKeyName: String)?
    public var getNodeApiKeyForApiKeyNameReceivedInvocations: [(chainId: String, apiKeyName: String)] = []
    public var getNodeApiKeyForApiKeyNameReturnValue: String?
    public var getNodeApiKeyForApiKeyNameClosure: ((String, String) -> String?)?

    public func getNodeApiKey(for chainId: String, apiKeyName: String) -> String? {
        getNodeApiKeyForApiKeyNameCallsCount += 1
        getNodeApiKeyForApiKeyNameReceivedArguments = (chainId: chainId, apiKeyName: apiKeyName)
        getNodeApiKeyForApiKeyNameReceivedInvocations.append((chainId: chainId, apiKeyName: apiKeyName))
        return getNodeApiKeyForApiKeyNameClosure.map({ $0(chainId, apiKeyName) }) ?? getNodeApiKeyForApiKeyNameReturnValue
    }

}
