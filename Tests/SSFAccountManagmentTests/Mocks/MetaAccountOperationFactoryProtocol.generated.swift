// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class MetaAccountOperationFactoryProtocolMock: MetaAccountOperationFactoryProtocol {

    //MARK: - newMetaAccountOperation

    var newMetaAccountOperationMnemonicRequestIsBackupedCallsCount = 0
    var newMetaAccountOperationMnemonicRequestIsBackupedCalled: Bool {
        return newMetaAccountOperationMnemonicRequestIsBackupedCallsCount > 0
    }
    var newMetaAccountOperationMnemonicRequestIsBackupedReceivedArguments: (mnemonicRequest: MetaAccountImportMnemonicRequest, isBackuped: Bool)?
    var newMetaAccountOperationMnemonicRequestIsBackupedReceivedInvocations: [(mnemonicRequest: MetaAccountImportMnemonicRequest, isBackuped: Bool)] = []
    var newMetaAccountOperationMnemonicRequestIsBackupedReturnValue: BaseOperation<MetaAccountModel>!
    var newMetaAccountOperationMnemonicRequestIsBackupedClosure: ((MetaAccountImportMnemonicRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    func newMetaAccountOperation(mnemonicRequest: MetaAccountImportMnemonicRequest, isBackuped: Bool) -> BaseOperation<MetaAccountModel> {
        newMetaAccountOperationMnemonicRequestIsBackupedCallsCount += 1
        newMetaAccountOperationMnemonicRequestIsBackupedReceivedArguments = (mnemonicRequest: mnemonicRequest, isBackuped: isBackuped)
        newMetaAccountOperationMnemonicRequestIsBackupedReceivedInvocations.append((mnemonicRequest: mnemonicRequest, isBackuped: isBackuped))
        return newMetaAccountOperationMnemonicRequestIsBackupedClosure.map({ $0(mnemonicRequest, isBackuped) }) ?? newMetaAccountOperationMnemonicRequestIsBackupedReturnValue
    }

    //MARK: - newMetaAccountOperation

    var newMetaAccountOperationSeedRequestIsBackupedCallsCount = 0
    var newMetaAccountOperationSeedRequestIsBackupedCalled: Bool {
        return newMetaAccountOperationSeedRequestIsBackupedCallsCount > 0
    }
    var newMetaAccountOperationSeedRequestIsBackupedReceivedArguments: (seedRequest: MetaAccountImportSeedRequest, isBackuped: Bool)?
    var newMetaAccountOperationSeedRequestIsBackupedReceivedInvocations: [(seedRequest: MetaAccountImportSeedRequest, isBackuped: Bool)] = []
    var newMetaAccountOperationSeedRequestIsBackupedReturnValue: BaseOperation<MetaAccountModel>!
    var newMetaAccountOperationSeedRequestIsBackupedClosure: ((MetaAccountImportSeedRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    func newMetaAccountOperation(seedRequest: MetaAccountImportSeedRequest, isBackuped: Bool) -> BaseOperation<MetaAccountModel> {
        newMetaAccountOperationSeedRequestIsBackupedCallsCount += 1
        newMetaAccountOperationSeedRequestIsBackupedReceivedArguments = (seedRequest: seedRequest, isBackuped: isBackuped)
        newMetaAccountOperationSeedRequestIsBackupedReceivedInvocations.append((seedRequest: seedRequest, isBackuped: isBackuped))
        return newMetaAccountOperationSeedRequestIsBackupedClosure.map({ $0(seedRequest, isBackuped) }) ?? newMetaAccountOperationSeedRequestIsBackupedReturnValue
    }

    //MARK: - newMetaAccountOperation

    var newMetaAccountOperationKeystoreRequestIsBackupedCallsCount = 0
    var newMetaAccountOperationKeystoreRequestIsBackupedCalled: Bool {
        return newMetaAccountOperationKeystoreRequestIsBackupedCallsCount > 0
    }
    var newMetaAccountOperationKeystoreRequestIsBackupedReceivedArguments: (keystoreRequest: MetaAccountImportKeystoreRequest, isBackuped: Bool)?
    var newMetaAccountOperationKeystoreRequestIsBackupedReceivedInvocations: [(keystoreRequest: MetaAccountImportKeystoreRequest, isBackuped: Bool)] = []
    var newMetaAccountOperationKeystoreRequestIsBackupedReturnValue: BaseOperation<MetaAccountModel>!
    var newMetaAccountOperationKeystoreRequestIsBackupedClosure: ((MetaAccountImportKeystoreRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    func newMetaAccountOperation(keystoreRequest: MetaAccountImportKeystoreRequest, isBackuped: Bool) -> BaseOperation<MetaAccountModel> {
        newMetaAccountOperationKeystoreRequestIsBackupedCallsCount += 1
        newMetaAccountOperationKeystoreRequestIsBackupedReceivedArguments = (keystoreRequest: keystoreRequest, isBackuped: isBackuped)
        newMetaAccountOperationKeystoreRequestIsBackupedReceivedInvocations.append((keystoreRequest: keystoreRequest, isBackuped: isBackuped))
        return newMetaAccountOperationKeystoreRequestIsBackupedClosure.map({ $0(keystoreRequest, isBackuped) }) ?? newMetaAccountOperationKeystoreRequestIsBackupedReturnValue
    }

    //MARK: - importChainAccountOperation

    var importChainAccountOperationMnemonicRequestCallsCount = 0
    var importChainAccountOperationMnemonicRequestCalled: Bool {
        return importChainAccountOperationMnemonicRequestCallsCount > 0
    }
    var importChainAccountOperationMnemonicRequestReceivedMnemonicRequest: ChainAccountImportMnemonicRequest?
    var importChainAccountOperationMnemonicRequestReceivedInvocations: [ChainAccountImportMnemonicRequest] = []
    var importChainAccountOperationMnemonicRequestReturnValue: BaseOperation<MetaAccountModel>!
    var importChainAccountOperationMnemonicRequestClosure: ((ChainAccountImportMnemonicRequest) -> BaseOperation<MetaAccountModel>)?

    func importChainAccountOperation(mnemonicRequest: ChainAccountImportMnemonicRequest) -> BaseOperation<MetaAccountModel> {
        importChainAccountOperationMnemonicRequestCallsCount += 1
        importChainAccountOperationMnemonicRequestReceivedMnemonicRequest = mnemonicRequest
        importChainAccountOperationMnemonicRequestReceivedInvocations.append(mnemonicRequest)
        return importChainAccountOperationMnemonicRequestClosure.map({ $0(mnemonicRequest) }) ?? importChainAccountOperationMnemonicRequestReturnValue
    }

    //MARK: - importChainAccountOperation

    var importChainAccountOperationSeedRequestCallsCount = 0
    var importChainAccountOperationSeedRequestCalled: Bool {
        return importChainAccountOperationSeedRequestCallsCount > 0
    }
    var importChainAccountOperationSeedRequestReceivedSeedRequest: ChainAccountImportSeedRequest?
    var importChainAccountOperationSeedRequestReceivedInvocations: [ChainAccountImportSeedRequest] = []
    var importChainAccountOperationSeedRequestReturnValue: BaseOperation<MetaAccountModel>!
    var importChainAccountOperationSeedRequestClosure: ((ChainAccountImportSeedRequest) -> BaseOperation<MetaAccountModel>)?

    func importChainAccountOperation(seedRequest: ChainAccountImportSeedRequest) -> BaseOperation<MetaAccountModel> {
        importChainAccountOperationSeedRequestCallsCount += 1
        importChainAccountOperationSeedRequestReceivedSeedRequest = seedRequest
        importChainAccountOperationSeedRequestReceivedInvocations.append(seedRequest)
        return importChainAccountOperationSeedRequestClosure.map({ $0(seedRequest) }) ?? importChainAccountOperationSeedRequestReturnValue
    }

    //MARK: - importChainAccountOperation

    var importChainAccountOperationKeystoreRequestCallsCount = 0
    var importChainAccountOperationKeystoreRequestCalled: Bool {
        return importChainAccountOperationKeystoreRequestCallsCount > 0
    }
    var importChainAccountOperationKeystoreRequestReceivedKeystoreRequest: ChainAccountImportKeystoreRequest?
    var importChainAccountOperationKeystoreRequestReceivedInvocations: [ChainAccountImportKeystoreRequest] = []
    var importChainAccountOperationKeystoreRequestReturnValue: BaseOperation<MetaAccountModel>!
    var importChainAccountOperationKeystoreRequestClosure: ((ChainAccountImportKeystoreRequest) -> BaseOperation<MetaAccountModel>)?

    func importChainAccountOperation(keystoreRequest: ChainAccountImportKeystoreRequest) -> BaseOperation<MetaAccountModel> {
        importChainAccountOperationKeystoreRequestCallsCount += 1
        importChainAccountOperationKeystoreRequestReceivedKeystoreRequest = keystoreRequest
        importChainAccountOperationKeystoreRequestReceivedInvocations.append(keystoreRequest)
        return importChainAccountOperationKeystoreRequestClosure.map({ $0(keystoreRequest) }) ?? importChainAccountOperationKeystoreRequestReturnValue
    }

}
