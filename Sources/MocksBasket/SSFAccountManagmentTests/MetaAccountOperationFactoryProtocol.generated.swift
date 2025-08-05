// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

public class MetaAccountOperationFactoryProtocolMock: MetaAccountOperationFactoryProtocol {
public init() {}

    //MARK: - newMetaAccountOperation

    public var newMetaAccountOperationMnemonicRequestIsBackedUpCallsCount = 0
    public var newMetaAccountOperationMnemonicRequestIsBackedUpCalled: Bool {
        return newMetaAccountOperationMnemonicRequestIsBackedUpCallsCount > 0
    }
    public var newMetaAccountOperationMnemonicRequestIsBackedUpReceivedArguments: (mnemonicRequest: MetaAccountImportMnemonicRequest, isBackedUp: Bool)?
    public var newMetaAccountOperationMnemonicRequestIsBackedUpReceivedInvocations: [(mnemonicRequest: MetaAccountImportMnemonicRequest, isBackedUp: Bool)] = []
    public var newMetaAccountOperationMnemonicRequestIsBackedUpReturnValue: BaseOperation<MetaAccountModel>!
    public var newMetaAccountOperationMnemonicRequestIsBackedUpClosure: ((MetaAccountImportMnemonicRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    public func newMetaAccountOperation(mnemonicRequest: MetaAccountImportMnemonicRequest, isBackedUp: Bool) -> BaseOperation<MetaAccountModel> {
        newMetaAccountOperationMnemonicRequestIsBackedUpCallsCount += 1
        newMetaAccountOperationMnemonicRequestIsBackedUpReceivedArguments = (mnemonicRequest: mnemonicRequest, isBackedUp: isBackedUp)
        newMetaAccountOperationMnemonicRequestIsBackedUpReceivedInvocations.append((mnemonicRequest: mnemonicRequest, isBackedUp: isBackedUp))
        return newMetaAccountOperationMnemonicRequestIsBackedUpClosure.map({ $0(mnemonicRequest, isBackedUp) }) ?? newMetaAccountOperationMnemonicRequestIsBackedUpReturnValue
    }

    //MARK: - newTonMetaAccountOperation

    public var newTonMetaAccountOperationMnemonicRequestIsBackedUpCallsCount = 0
    public var newTonMetaAccountOperationMnemonicRequestIsBackedUpCalled: Bool {
        return newTonMetaAccountOperationMnemonicRequestIsBackedUpCallsCount > 0
    }
    public var newTonMetaAccountOperationMnemonicRequestIsBackedUpReceivedArguments: (mnemonicRequest: MetaAccountImportTonMnemonicRequest, isBackedUp: Bool)?
    public var newTonMetaAccountOperationMnemonicRequestIsBackedUpReceivedInvocations: [(mnemonicRequest: MetaAccountImportTonMnemonicRequest, isBackedUp: Bool)] = []
    public var newTonMetaAccountOperationMnemonicRequestIsBackedUpReturnValue: BaseOperation<MetaAccountModel>!
    public var newTonMetaAccountOperationMnemonicRequestIsBackedUpClosure: ((MetaAccountImportTonMnemonicRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    public func newTonMetaAccountOperation(mnemonicRequest: MetaAccountImportTonMnemonicRequest, isBackedUp: Bool) -> BaseOperation<MetaAccountModel> {
        newTonMetaAccountOperationMnemonicRequestIsBackedUpCallsCount += 1
        newTonMetaAccountOperationMnemonicRequestIsBackedUpReceivedArguments = (mnemonicRequest: mnemonicRequest, isBackedUp: isBackedUp)
        newTonMetaAccountOperationMnemonicRequestIsBackedUpReceivedInvocations.append((mnemonicRequest: mnemonicRequest, isBackedUp: isBackedUp))
        return newTonMetaAccountOperationMnemonicRequestIsBackedUpClosure.map({ $0(mnemonicRequest, isBackedUp) }) ?? newTonMetaAccountOperationMnemonicRequestIsBackedUpReturnValue
    }

    //MARK: - newMetaAccountOperation

    public var newMetaAccountOperationSeedRequestIsBackedUpCallsCount = 0
    public var newMetaAccountOperationSeedRequestIsBackedUpCalled: Bool {
        return newMetaAccountOperationSeedRequestIsBackedUpCallsCount > 0
    }
    public var newMetaAccountOperationSeedRequestIsBackedUpReceivedArguments: (seedRequest: MetaAccountImportSeedRequest, isBackedUp: Bool)?
    public var newMetaAccountOperationSeedRequestIsBackedUpReceivedInvocations: [(seedRequest: MetaAccountImportSeedRequest, isBackedUp: Bool)] = []
    public var newMetaAccountOperationSeedRequestIsBackedUpReturnValue: BaseOperation<MetaAccountModel>!
    public var newMetaAccountOperationSeedRequestIsBackedUpClosure: ((MetaAccountImportSeedRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    public func newMetaAccountOperation(seedRequest: MetaAccountImportSeedRequest, isBackedUp: Bool) -> BaseOperation<MetaAccountModel> {
        newMetaAccountOperationSeedRequestIsBackedUpCallsCount += 1
        newMetaAccountOperationSeedRequestIsBackedUpReceivedArguments = (seedRequest: seedRequest, isBackedUp: isBackedUp)
        newMetaAccountOperationSeedRequestIsBackedUpReceivedInvocations.append((seedRequest: seedRequest, isBackedUp: isBackedUp))
        return newMetaAccountOperationSeedRequestIsBackedUpClosure.map({ $0(seedRequest, isBackedUp) }) ?? newMetaAccountOperationSeedRequestIsBackedUpReturnValue
    }

    //MARK: - newMetaAccountOperation

    public var newMetaAccountOperationKeystoreRequestIsBackedUpCallsCount = 0
    public var newMetaAccountOperationKeystoreRequestIsBackedUpCalled: Bool {
        return newMetaAccountOperationKeystoreRequestIsBackedUpCallsCount > 0
    }
    public var newMetaAccountOperationKeystoreRequestIsBackedUpReceivedArguments: (keystoreRequest: MetaAccountImportKeystoreRequest, isBackedUp: Bool)?
    public var newMetaAccountOperationKeystoreRequestIsBackedUpReceivedInvocations: [(keystoreRequest: MetaAccountImportKeystoreRequest, isBackedUp: Bool)] = []
    public var newMetaAccountOperationKeystoreRequestIsBackedUpReturnValue: BaseOperation<MetaAccountModel>!
    public var newMetaAccountOperationKeystoreRequestIsBackedUpClosure: ((MetaAccountImportKeystoreRequest, Bool) -> BaseOperation<MetaAccountModel>)?

    public func newMetaAccountOperation(keystoreRequest: MetaAccountImportKeystoreRequest, isBackedUp: Bool) -> BaseOperation<MetaAccountModel> {
        newMetaAccountOperationKeystoreRequestIsBackedUpCallsCount += 1
        newMetaAccountOperationKeystoreRequestIsBackedUpReceivedArguments = (keystoreRequest: keystoreRequest, isBackedUp: isBackedUp)
        newMetaAccountOperationKeystoreRequestIsBackedUpReceivedInvocations.append((keystoreRequest: keystoreRequest, isBackedUp: isBackedUp))
        return newMetaAccountOperationKeystoreRequestIsBackedUpClosure.map({ $0(keystoreRequest, isBackedUp) }) ?? newMetaAccountOperationKeystoreRequestIsBackedUpReturnValue
    }

    //MARK: - importChainAccountOperation

    public var importChainAccountOperationMnemonicRequestCallsCount = 0
    public var importChainAccountOperationMnemonicRequestCalled: Bool {
        return importChainAccountOperationMnemonicRequestCallsCount > 0
    }
    public var importChainAccountOperationMnemonicRequestReceivedMnemonicRequest: ChainAccountImportMnemonicRequest?
    public var importChainAccountOperationMnemonicRequestReceivedInvocations: [ChainAccountImportMnemonicRequest] = []
    public var importChainAccountOperationMnemonicRequestReturnValue: BaseOperation<MetaAccountModel>!
    public var importChainAccountOperationMnemonicRequestClosure: ((ChainAccountImportMnemonicRequest) -> BaseOperation<MetaAccountModel>)?

    public func importChainAccountOperation(mnemonicRequest: ChainAccountImportMnemonicRequest) -> BaseOperation<MetaAccountModel> {
        importChainAccountOperationMnemonicRequestCallsCount += 1
        importChainAccountOperationMnemonicRequestReceivedMnemonicRequest = mnemonicRequest
        importChainAccountOperationMnemonicRequestReceivedInvocations.append(mnemonicRequest)
        return importChainAccountOperationMnemonicRequestClosure.map({ $0(mnemonicRequest) }) ?? importChainAccountOperationMnemonicRequestReturnValue
    }

    //MARK: - importChainAccountOperation

    public var importChainAccountOperationSeedRequestCallsCount = 0
    public var importChainAccountOperationSeedRequestCalled: Bool {
        return importChainAccountOperationSeedRequestCallsCount > 0
    }
    public var importChainAccountOperationSeedRequestReceivedSeedRequest: ChainAccountImportSeedRequest?
    public var importChainAccountOperationSeedRequestReceivedInvocations: [ChainAccountImportSeedRequest] = []
    public var importChainAccountOperationSeedRequestReturnValue: BaseOperation<MetaAccountModel>!
    public var importChainAccountOperationSeedRequestClosure: ((ChainAccountImportSeedRequest) -> BaseOperation<MetaAccountModel>)?

    public func importChainAccountOperation(seedRequest: ChainAccountImportSeedRequest) -> BaseOperation<MetaAccountModel> {
        importChainAccountOperationSeedRequestCallsCount += 1
        importChainAccountOperationSeedRequestReceivedSeedRequest = seedRequest
        importChainAccountOperationSeedRequestReceivedInvocations.append(seedRequest)
        return importChainAccountOperationSeedRequestClosure.map({ $0(seedRequest) }) ?? importChainAccountOperationSeedRequestReturnValue
    }

    //MARK: - importChainAccountOperation

    public var importChainAccountOperationKeystoreRequestCallsCount = 0
    public var importChainAccountOperationKeystoreRequestCalled: Bool {
        return importChainAccountOperationKeystoreRequestCallsCount > 0
    }
    public var importChainAccountOperationKeystoreRequestReceivedKeystoreRequest: ChainAccountImportKeystoreRequest?
    public var importChainAccountOperationKeystoreRequestReceivedInvocations: [ChainAccountImportKeystoreRequest] = []
    public var importChainAccountOperationKeystoreRequestReturnValue: BaseOperation<MetaAccountModel>!
    public var importChainAccountOperationKeystoreRequestClosure: ((ChainAccountImportKeystoreRequest) -> BaseOperation<MetaAccountModel>)?

    public func importChainAccountOperation(keystoreRequest: ChainAccountImportKeystoreRequest) -> BaseOperation<MetaAccountModel> {
        importChainAccountOperationKeystoreRequestCallsCount += 1
        importChainAccountOperationKeystoreRequestReceivedKeystoreRequest = keystoreRequest
        importChainAccountOperationKeystoreRequestReceivedInvocations.append(keystoreRequest)
        return importChainAccountOperationKeystoreRequestClosure.map({ $0(keystoreRequest) }) ?? importChainAccountOperationKeystoreRequestReturnValue
    }

}
