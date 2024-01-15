// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class AccountManagebleMock: AccountManageble {

    //MARK: - getCurrentAccount

    var getCurrentAccountCallsCount = 0
    var getCurrentAccountCalled: Bool {
        return getCurrentAccountCallsCount > 0
    }
    var getCurrentAccountReturnValue: MetaAccountModel?
    var getCurrentAccountClosure: (() -> MetaAccountModel?)?

    func getCurrentAccount() -> MetaAccountModel? {
        getCurrentAccountCallsCount += 1
        return getCurrentAccountClosure.map({ $0() }) ?? getCurrentAccountReturnValue
    }

    //MARK: - setCurrentAccount

    var setCurrentAccountAccountCompletionClosureCallsCount = 0
    var setCurrentAccountAccountCompletionClosureCalled: Bool {
        return setCurrentAccountAccountCompletionClosureCallsCount > 0
    }
    var setCurrentAccountAccountCompletionClosureReceivedArguments: (account: MetaAccountModel, completionClosure: (Result<MetaAccountModel, Error>) -> Void)?
    var setCurrentAccountAccountCompletionClosureReceivedInvocations: [(account: MetaAccountModel, completionClosure: (Result<MetaAccountModel, Error>) -> Void)] = []
    var setCurrentAccountAccountCompletionClosureClosure: ((MetaAccountModel, @escaping (Result<MetaAccountModel, Error>) -> Void) -> Void)?

    func setCurrentAccount(account: MetaAccountModel, completionClosure: @escaping (Result<MetaAccountModel, Error>) -> Void) {
        setCurrentAccountAccountCompletionClosureCallsCount += 1
        setCurrentAccountAccountCompletionClosureReceivedArguments = (account: account, completionClosure: completionClosure)
        setCurrentAccountAccountCompletionClosureReceivedInvocations.append((account: account, completionClosure: completionClosure))
        setCurrentAccountAccountCompletionClosureClosure?(account, completionClosure)
    }

    //MARK: - update

    var updateVisibleForCompletionThrowableError: Error?
    var updateVisibleForCompletionCallsCount = 0
    var updateVisibleForCompletionCalled: Bool {
        return updateVisibleForCompletionCallsCount > 0
    }
    var updateVisibleForCompletionReceivedArguments: (visible: Bool, chainAsset: ChainAsset, completion: () -> Void)?
    var updateVisibleForCompletionReceivedInvocations: [(visible: Bool, chainAsset: ChainAsset, completion: () -> Void)] = []
    var updateVisibleForCompletionClosure: ((Bool, ChainAsset, @escaping () -> Void) throws -> Void)?

    func update(visible: Bool, for chainAsset: ChainAsset, completion: @escaping () -> Void) throws {
        if let error = updateVisibleForCompletionThrowableError {
            throw error
        }
        updateVisibleForCompletionCallsCount += 1
        updateVisibleForCompletionReceivedArguments = (visible: visible, chainAsset: chainAsset, completion: completion)
        updateVisibleForCompletionReceivedInvocations.append((visible: visible, chainAsset: chainAsset, completion: completion))
        try updateVisibleForCompletionClosure?(visible, chainAsset, completion)
    }

    //MARK: - logout

    var logoutThrowableError: Error?
    var logoutCallsCount = 0
    var logoutCalled: Bool {
        return logoutCallsCount > 0
    }
    var logoutClosure: (() throws -> Void)?

    func logout() throws {
        if let error = logoutThrowableError {
            throw error
        }
        logoutCallsCount += 1
        try logoutClosure?()
    }

}
