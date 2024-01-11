// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class MnemonicExportDataFactoryProtocolMock: MnemonicExportDataFactoryProtocol {

    //MARK: - createMnemonicExportData

    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainThrowableError: Error?
    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainCallsCount = 0
    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainCalled: Bool {
        return createMnemonicExportDataMetaIdAccountIdCryptoTypeChainCallsCount > 0
    }
    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainReceivedArguments: (metaId: MetaAccountId, accountId: AccountId?, cryptoType: CryptoType?, chain: ChainModel)?
    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainReceivedInvocations: [(metaId: MetaAccountId, accountId: AccountId?, cryptoType: CryptoType?, chain: ChainModel)] = []
    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainReturnValue: MnemonicExportData!
    var createMnemonicExportDataMetaIdAccountIdCryptoTypeChainClosure: ((MetaAccountId, AccountId?, CryptoType?, ChainModel) throws -> MnemonicExportData)?

    func createMnemonicExportData(metaId: MetaAccountId, accountId: AccountId?, cryptoType: CryptoType?, chain: ChainModel) throws -> MnemonicExportData {
        if let error = createMnemonicExportDataMetaIdAccountIdCryptoTypeChainThrowableError {
            throw error
        }
        createMnemonicExportDataMetaIdAccountIdCryptoTypeChainCallsCount += 1
        createMnemonicExportDataMetaIdAccountIdCryptoTypeChainReceivedArguments = (metaId: metaId, accountId: accountId, cryptoType: cryptoType, chain: chain)
        createMnemonicExportDataMetaIdAccountIdCryptoTypeChainReceivedInvocations.append((metaId: metaId, accountId: accountId, cryptoType: cryptoType, chain: chain))
        return try createMnemonicExportDataMetaIdAccountIdCryptoTypeChainClosure.map({ try $0(metaId, accountId, cryptoType, chain) }) ?? createMnemonicExportDataMetaIdAccountIdCryptoTypeChainReturnValue
    }

}
