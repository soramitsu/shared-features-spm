// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class AccountImportableMock: AccountImportable {

    //MARK: - importMetaAccount

    var importMetaAccountRequestThrowableError: Error?
    var importMetaAccountRequestCallsCount = 0
    var importMetaAccountRequestCalled: Bool {
        return importMetaAccountRequestCallsCount > 0
    }
    var importMetaAccountRequestReceivedRequest: MetaAccountImportRequest?
    var importMetaAccountRequestReceivedInvocations: [MetaAccountImportRequest] = []
    var importMetaAccountRequestReturnValue: MetaAccountModel!
    var importMetaAccountRequestClosure: ((MetaAccountImportRequest) throws -> MetaAccountModel)?

    func importMetaAccount(request: MetaAccountImportRequest) throws -> MetaAccountModel {
        if let error = importMetaAccountRequestThrowableError {
            throw error
        }
        importMetaAccountRequestCallsCount += 1
        importMetaAccountRequestReceivedRequest = request
        importMetaAccountRequestReceivedInvocations.append(request)
        return try importMetaAccountRequestClosure.map({ try $0(request) }) ?? importMetaAccountRequestReturnValue
    }

}
