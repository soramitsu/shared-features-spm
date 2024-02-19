// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFXCM
@testable import RobinHood
@testable import SSFUtils
@testable import SSFModels
@testable import SSFChainConnection
@testable import SSFRuntimeCodingService
@testable import SSFChainRegistry

class ChainRegistryProtocolMock: ChainRegistryProtocol {

    //MARK: - getRuntimeProvider

    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemThrowableError: Error?
    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCallsCount = 0
    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCalled: Bool {
        return getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCallsCount > 0
    }
    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedArguments: (chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)?
    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedInvocations: [(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)] = []
    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReturnValue: RuntimeProviderProtocol!
    var getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemClosure: ((ChainModel.Id, [String: [String]], RuntimeMetadataItemProtocol?) throws -> RuntimeProviderProtocol)?

    func getRuntimeProvider(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?) throws -> RuntimeProviderProtocol {
        if let error = getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemThrowableError {
            throw error
        }
        getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemCallsCount += 1
        getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedArguments = (chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem)
        getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReceivedInvocations.append((chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem))
        return try getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemClosure.map({ try $0(chainId, usedRuntimePaths, runtimeItem) }) ?? getRuntimeProviderChainIdUsedRuntimePathsRuntimeItemReturnValue
    }

    //MARK: - getConnection

    var getConnectionForThrowableError: Error?
    var getConnectionForCallsCount = 0
    var getConnectionForCalled: Bool {
        return getConnectionForCallsCount > 0
    }
    var getConnectionForReceivedChain: ChainModel?
    var getConnectionForReceivedInvocations: [ChainModel] = []
    var getConnectionForReturnValue: ChainConnection!
    var getConnectionForClosure: ((ChainModel) throws -> ChainConnection)?

    func getConnection(for chain: ChainModel) throws -> ChainConnection {
        if let error = getConnectionForThrowableError {
            throw error
        }
        getConnectionForCallsCount += 1
        getConnectionForReceivedChain = chain
        getConnectionForReceivedInvocations.append(chain)
        return try getConnectionForClosure.map({ try $0(chain) }) ?? getConnectionForReturnValue
    }

    //MARK: - getChain

    var getChainForThrowableError: Error?
    var getChainForCallsCount = 0
    var getChainForCalled: Bool {
        return getChainForCallsCount > 0
    }
    var getChainForReceivedChainId: ChainModel.Id?
    var getChainForReceivedInvocations: [ChainModel.Id] = []
    var getChainForReturnValue: ChainModel!
    var getChainForClosure: ((ChainModel.Id) throws -> ChainModel)?

    func getChain(for chainId: ChainModel.Id) throws -> ChainModel {
        if let error = getChainForThrowableError {
            throw error
        }
        getChainForCallsCount += 1
        getChainForReceivedChainId = chainId
        getChainForReceivedInvocations.append(chainId)
        return try getChainForClosure.map({ try $0(chainId) }) ?? getChainForReturnValue
    }

    //MARK: - getChains

    var getChainsThrowableError: Error?
    var getChainsCallsCount = 0
    var getChainsCalled: Bool {
        return getChainsCallsCount > 0
    }
    var getChainsReturnValue: [ChainModel]!
    var getChainsClosure: (() throws -> [ChainModel])?

    func getChains() throws -> [ChainModel] {
        if let error = getChainsThrowableError {
            throw error
        }
        getChainsCallsCount += 1
        return try getChainsClosure.map({ try $0() }) ?? getChainsReturnValue
    }

    //MARK: - getReadySnapshot

    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemThrowableError: Error?
    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCallsCount = 0
    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCalled: Bool {
        return getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCallsCount > 0
    }
    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedArguments: (chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)?
    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedInvocations: [(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?)] = []
    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReturnValue: RuntimeSnapshot!
    var getReadySnapshotChainIdUsedRuntimePathsRuntimeItemClosure: ((ChainModel.Id, [String: [String]], RuntimeMetadataItemProtocol?) throws -> RuntimeSnapshot)?

    func getReadySnapshot(chainId: ChainModel.Id, usedRuntimePaths: [String: [String]], runtimeItem: RuntimeMetadataItemProtocol?) throws -> RuntimeSnapshot {
        if let error = getReadySnapshotChainIdUsedRuntimePathsRuntimeItemThrowableError {
            throw error
        }
        getReadySnapshotChainIdUsedRuntimePathsRuntimeItemCallsCount += 1
        getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedArguments = (chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem)
        getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReceivedInvocations.append((chainId: chainId, usedRuntimePaths: usedRuntimePaths, runtimeItem: runtimeItem))
        return try getReadySnapshotChainIdUsedRuntimePathsRuntimeItemClosure.map({ try $0(chainId, usedRuntimePaths, runtimeItem) }) ?? getReadySnapshotChainIdUsedRuntimePathsRuntimeItemReturnValue
    }

}
