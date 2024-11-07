// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

public class AccountManagebleMock: AccountManageble {
public init() {}

    //MARK: - getCurrentAccount

    public var getCurrentAccountCallsCount = 0
    public var getCurrentAccountCalled: Bool {
        return getCurrentAccountCallsCount > 0
    }
    public var getCurrentAccountReturnValue: MetaAccountModel?
    public var getCurrentAccountClosure: (() -> MetaAccountModel?)?

    public func getCurrentAccount() -> MetaAccountModel? {
        getCurrentAccountCallsCount += 1
        return getCurrentAccountClosure.map({ $0() }) ?? getCurrentAccountReturnValue
    }

    //MARK: - setCurrentAccount

    public var setCurrentAccountAccountCompletionClosureCallsCount = 0
    public var setCurrentAccountAccountCompletionClosureCalled: Bool {
        return setCurrentAccountAccountCompletionClosureCallsCount > 0
    }
    public var setCurrentAccountAccountCompletionClosureReceivedArguments: (account: MetaAccountModel, completionClosure: (Result<MetaAccountModel, Error>) -> Void)?
    public var setCurrentAccountAccountCompletionClosureReceivedInvocations: [(account: MetaAccountModel, completionClosure: (Result<MetaAccountModel, Error>) -> Void)] = []
    public var setCurrentAccountAccountCompletionClosureClosure: ((MetaAccountModel, @escaping (Result<MetaAccountModel, Error>) -> Void) -> Void)?

    public func setCurrentAccount(account: MetaAccountModel, completionClosure: @escaping (Result<MetaAccountModel, Error>) -> Void) {
        setCurrentAccountAccountCompletionClosureCallsCount += 1
        setCurrentAccountAccountCompletionClosureReceivedArguments = (account: account, completionClosure: completionClosure)
        setCurrentAccountAccountCompletionClosureReceivedInvocations.append((account: account, completionClosure: completionClosure))
        setCurrentAccountAccountCompletionClosureClosure?(account, completionClosure)
    }

    //MARK: - getAllAccounts

    public var getAllAccountsThrowableError: Error?
    public var getAllAccountsCallsCount = 0
    public var getAllAccountsCalled: Bool {
        return getAllAccountsCallsCount > 0
    }
    public var getAllAccountsReturnValue: [MetaAccountModel]!
    public var getAllAccountsClosure: (() throws -> [MetaAccountModel])?

    public func getAllAccounts() throws -> [MetaAccountModel] {
        if let error = getAllAccountsThrowableError {
            throw error
        }
        getAllAccountsCallsCount += 1
        return try getAllAccountsClosure.map({ try $0() }) ?? getAllAccountsReturnValue
    }

    //MARK: - updateEnabilibilty

    public var updateEnabilibiltyForThrowableError: Error?
    public var updateEnabilibiltyForCallsCount = 0
    public var updateEnabilibiltyForCalled: Bool {
        return updateEnabilibiltyForCallsCount > 0
    }
    public var updateEnabilibiltyForReceivedChainAssetId: String?
    public var updateEnabilibiltyForReceivedInvocations: [String] = []
    public var updateEnabilibiltyForReturnValue: MetaAccountModel!
    public var updateEnabilibiltyForClosure: ((String) throws -> MetaAccountModel)?

    public func updateEnabilibilty(for chainAssetId: String) throws -> MetaAccountModel {
        if let error = updateEnabilibiltyForThrowableError {
            throw error
        }
        updateEnabilibiltyForCallsCount += 1
        updateEnabilibiltyForReceivedChainAssetId = chainAssetId
        updateEnabilibiltyForReceivedInvocations.append(chainAssetId)
        return try updateEnabilibiltyForClosure.map({ try $0(chainAssetId) }) ?? updateEnabilibiltyForReturnValue
    }

    //MARK: - updateFavourite

    public var updateFavouriteForThrowableError: Error?
    public var updateFavouriteForCallsCount = 0
    public var updateFavouriteForCalled: Bool {
        return updateFavouriteForCallsCount > 0
    }
    public var updateFavouriteForReceivedChainId: String?
    public var updateFavouriteForReceivedInvocations: [String] = []
    public var updateFavouriteForReturnValue: MetaAccountModel!
    public var updateFavouriteForClosure: ((String) throws -> MetaAccountModel)?

    public func updateFavourite(for chainId: String) throws -> MetaAccountModel {
        if let error = updateFavouriteForThrowableError {
            throw error
        }
        updateFavouriteForCallsCount += 1
        updateFavouriteForReceivedChainId = chainId
        updateFavouriteForReceivedInvocations.append(chainId)
        return try updateFavouriteForClosure.map({ try $0(chainId) }) ?? updateFavouriteForReturnValue
    }

    //MARK: - update

    public var updateEnabledAssetIdsThrowableError: Error?
    public var updateEnabledAssetIdsCallsCount = 0
    public var updateEnabledAssetIdsCalled: Bool {
        return updateEnabledAssetIdsCallsCount > 0
    }
    public var updateEnabledAssetIdsReceivedEnabledAssetIds: Set<String>?
    public var updateEnabledAssetIdsReceivedInvocations: [Set<String>] = []
    public var updateEnabledAssetIdsReturnValue: MetaAccountModel!
    public var updateEnabledAssetIdsClosure: ((Set<String>) throws -> MetaAccountModel)?

    public func update(enabledAssetIds: Set<String>) throws -> MetaAccountModel {
        if let error = updateEnabledAssetIdsThrowableError {
            throw error
        }
        updateEnabledAssetIdsCallsCount += 1
        updateEnabledAssetIdsReceivedEnabledAssetIds = enabledAssetIds
        updateEnabledAssetIdsReceivedInvocations.append(enabledAssetIds)
        return try updateEnabledAssetIdsClosure.map({ try $0(enabledAssetIds) }) ?? updateEnabledAssetIdsReturnValue
    }

    //MARK: - logout

    public var logoutThrowableError: Error?
    public var logoutCallsCount = 0
    public var logoutCalled: Bool {
        return logoutCallsCount > 0
    }
    public var logoutClosure: (() throws -> Void)?

    public func logout() throws {
        if let error = logoutThrowableError {
            throw error
        }
        logoutCallsCount += 1
        try logoutClosure?()
    }

}
