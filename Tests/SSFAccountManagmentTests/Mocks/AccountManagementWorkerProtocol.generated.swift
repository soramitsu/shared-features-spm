// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class AccountManagementWorkerProtocolMock: AccountManagementWorkerProtocol {

    //MARK: - save

    var saveAccountCompletionCallsCount = 0
    var saveAccountCompletionCalled: Bool {
        return saveAccountCompletionCallsCount > 0
    }
    var saveAccountCompletionReceivedArguments: (account: ManagedMetaAccountModel, completion: () -> Void)?
    var saveAccountCompletionReceivedInvocations: [(account: ManagedMetaAccountModel, completion: () -> Void)] = []
    var saveAccountCompletionClosure: ((ManagedMetaAccountModel, @escaping () -> Void) -> Void)?

    func save(account: ManagedMetaAccountModel, completion: @escaping () -> Void) {
        saveAccountCompletionCallsCount += 1
        saveAccountCompletionReceivedArguments = (account: account, completion: completion)
        saveAccountCompletionReceivedInvocations.append((account: account, completion: completion))
        saveAccountCompletionClosure?(account, completion)
    }

    //MARK: - fetchAll

    var fetchAllThrowableError: Error?
    var fetchAllCallsCount = 0
    var fetchAllCalled: Bool {
        return fetchAllCallsCount > 0
    }
    var fetchAllReturnValue: [MetaAccountModel]!
    var fetchAllClosure: (() throws -> [MetaAccountModel])?

    func fetchAll() throws -> [MetaAccountModel] {
        if let error = fetchAllThrowableError {
            throw error
        }
        fetchAllCallsCount += 1
        return try fetchAllClosure.map({ try $0() }) ?? fetchAllReturnValue
    }

    //MARK: - deleteAll

    var deleteAllCompletionCallsCount = 0
    var deleteAllCompletionCalled: Bool {
        return deleteAllCompletionCallsCount > 0
    }
    var deleteAllCompletionReceivedCompletion: (() -> Void)?
    var deleteAllCompletionReceivedInvocations: [(() -> Void)] = []
    var deleteAllCompletionClosure: ((@escaping () -> Void) -> Void)?

    func deleteAll(completion: @escaping () -> Void) {
        deleteAllCompletionCallsCount += 1
        deleteAllCompletionReceivedCompletion = completion
        deleteAllCompletionReceivedInvocations.append(completion)
        deleteAllCompletionClosure?(completion)
    }

}
