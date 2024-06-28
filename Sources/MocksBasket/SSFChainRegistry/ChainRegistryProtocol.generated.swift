// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import Web3
@testable import SSFUtils
@testable import RobinHood
@testable import SSFModels
@testable import SSFRuntimeCodingService
@testable import SSFChainConnection
@testable import SSFNetwork
@testable import SSFLogger
@testable import SSFChainRegistry

public class ChainRegistryProtocolMock: ChainRegistryProtocol {
public init() {}

    //MARK: - getRuntimeProvider

    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemThrowableError: Error?
    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCallsCount = 0
    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCalled: Bool {
        return getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCallsCount > 0
    }
    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedArguments: (chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)?
    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedInvocations: [(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)] = []
    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReturnValue: RuntimeProviderProtocol!
    public var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemClosure: ((ChainModel.Id, [String: [String]], RuntimeMetadataItemProtocol?) throws -> RuntimeProviderProtocol)?

    public func getRuntimeProvider(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?) throws -> RuntimeProviderProtocol {
        if let error = getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemThrowableError {
            throw error
        }
        getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCallsCount += 1
        getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedArguments = (chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem)
        getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedInvocations.append((chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem))
        return try getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemClosure.map({ try $0(chainId, usedRuntimePaths, runtimeItem) }) ?? getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReturnValue
    }

    //MARK: - getRuntimeProvider

    public var getRuntimeProviderForCallsCount = 0
    public var getRuntimeProviderForCalled: Bool {
        return getRuntimeProviderForCallsCount > 0
    }
    public var getRuntimeProviderForReceivedChainId: ChainModel.Id?
    public var getRuntimeProviderForReceivedInvocations: [ChainModel.Id] = []
    public var getRuntimeProviderForReturnValue: RuntimeProviderProtocol?
    public var getRuntimeProviderForClosure: ((ChainModel.Id) -> RuntimeProviderProtocol?)?

    public func getRuntimeProvider(for chainId: ChainModel.Id) -> RuntimeProviderProtocol? {
        getRuntimeProviderForCallsCount += 1
        getRuntimeProviderForReceivedChainId = chainId
        getRuntimeProviderForReceivedInvocations.append(chainId)
        return getRuntimeProviderForClosure.map({ $0(chainId) }) ?? getRuntimeProviderForReturnValue
    }

    //MARK: - getSubstrateConnection

    public var getSubstrateConnectionForThrowableError: Error?
    public var getSubstrateConnectionForCallsCount = 0
    public var getSubstrateConnectionForCalled: Bool {
        return getSubstrateConnectionForCallsCount > 0
    }
    public var getSubstrateConnectionForReceivedChain: ChainModel?
    public var getSubstrateConnectionForReceivedInvocations: [ChainModel] = []
    public var getSubstrateConnectionForReturnValue: SubstrateConnection!
    public var getSubstrateConnectionForClosure: ((ChainModel) throws -> SubstrateConnection)?

    public func getSubstrateConnection(for chain: ChainModel) throws -> SubstrateConnection {
        if let error = getSubstrateConnectionForThrowableError {
            throw error
        }
        getSubstrateConnectionForCallsCount += 1
        getSubstrateConnectionForReceivedChain = chain
        getSubstrateConnectionForReceivedInvocations.append(chain)
        return try getSubstrateConnectionForClosure.map({ try $0(chain) }) ?? getSubstrateConnectionForReturnValue
    }

    //MARK: - getEthereumConnection

    public var getEthereumConnectionForThrowableError: Error?
    public var getEthereumConnectionForCallsCount = 0
    public var getEthereumConnectionForCalled: Bool {
        return getEthereumConnectionForCallsCount > 0
    }
    public var getEthereumConnectionForReceivedChain: ChainModel?
    public var getEthereumConnectionForReceivedInvocations: [ChainModel] = []
    public var getEthereumConnectionForReturnValue: Web3EthConnection!
    public var getEthereumConnectionForClosure: ((ChainModel) throws -> Web3EthConnection)?

    public func getEthereumConnection(for chain: ChainModel) throws -> Web3EthConnection {
        if let error = getEthereumConnectionForThrowableError {
            throw error
        }
        getEthereumConnectionForCallsCount += 1
        getEthereumConnectionForReceivedChain = chain
        getEthereumConnectionForReceivedInvocations.append(chain)
        return try getEthereumConnectionForClosure.map({ try $0(chain) }) ?? getEthereumConnectionForReturnValue
    }

    //MARK: - getChain

    public var getChainForThrowableError: Error?
    public var getChainForCallsCount = 0
    public var getChainForCalled: Bool {
        return getChainForCallsCount > 0
    }
    public var getChainForReceivedChainId: ChainModel.Id?
    public var getChainForReceivedInvocations: [ChainModel.Id] = []
    public var getChainForReturnValue: ChainModel!
    public var getChainForClosure: ((ChainModel.Id) throws -> ChainModel)?

    public func getChain(for chainId: ChainModel.Id) throws -> ChainModel {
        if let error = getChainForThrowableError {
            throw error
        }
        getChainForCallsCount += 1
        getChainForReceivedChainId = chainId
        getChainForReceivedInvocations.append(chainId)
        return try getChainForClosure.map({ try $0(chainId) }) ?? getChainForReturnValue
    }

    //MARK: - getChains

    public var getChainsThrowableError: Error?
    public var getChainsCallsCount = 0
    public var getChainsCalled: Bool {
        return getChainsCallsCount > 0
    }
    public var getChainsReturnValue: [ChainModel]!
    public var getChainsClosure: (() throws -> [ChainModel])?

    public func getChains() throws -> [ChainModel] {
        if let error = getChainsThrowableError {
            throw error
        }
        getChainsCallsCount += 1
        return try getChainsClosure.map({ try $0() }) ?? getChainsReturnValue
    }

    //MARK: - getReadySnapshot

    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemThrowableError: Error?
    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCallsCount = 0
    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCalled: Bool {
        return getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCallsCount > 0
    }
    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedArguments: (chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)?
    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedInvocations: [(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)] = []
    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReturnValue: RuntimeSnapshot!
    public var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemClosure: ((ChainModel.Id, [String: [String]], RuntimeMetadataItemProtocol?) throws -> RuntimeSnapshot)?

    public func getReadySnapshot(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?) throws -> RuntimeSnapshot {
        if let error = getReadySnapshotChainIdUsedRuntimePathsRuntimeItemThrowableError {
            throw error
        }
        getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCallsCount += 1
        getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedArguments = (chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem)
        getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedInvocations.append((chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem))
        return try getReadySnapshotChainIdUsedRuntimePathsRuntimeItemClosure.map({ try $0(chainId, usedRuntimePaths, runtimeItem) }) ?? getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReturnValue
    }

}
