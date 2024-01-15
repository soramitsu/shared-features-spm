// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class SeedExportDataFactoryProtocolMock: SeedExportDataFactoryProtocol {

    //MARK: - createSeedExportData

    var createSeedExportDataMetaIdAccountIdCryptoTypeChainThrowableError: Error?
    var createSeedExportDataMetaIdAccountIdCryptoTypeChainCallsCount = 0
    var createSeedExportDataMetaIdAccountIdCryptoTypeChainCalled: Bool {
        return createSeedExportDataMetaIdAccountIdCryptoTypeChainCallsCount > 0
    }
    var createSeedExportDataMetaIdAccountIdCryptoTypeChainReceivedArguments: (metaId: MetaAccountId, accountId: AccountId?, cryptoType: CryptoType, chain: ChainModel)?
    var createSeedExportDataMetaIdAccountIdCryptoTypeChainReceivedInvocations: [(metaId: MetaAccountId, accountId: AccountId?, cryptoType: CryptoType, chain: ChainModel)] = []
    var createSeedExportDataMetaIdAccountIdCryptoTypeChainReturnValue: SeedExportData!
    var createSeedExportDataMetaIdAccountIdCryptoTypeChainClosure: ((MetaAccountId, AccountId?, CryptoType, ChainModel) throws -> SeedExportData)?

    func createSeedExportData(metaId: MetaAccountId, accountId: AccountId?, cryptoType: CryptoType, chain: ChainModel) throws -> SeedExportData {
        if let error = createSeedExportDataMetaIdAccountIdCryptoTypeChainThrowableError {
            throw error
        }
        createSeedExportDataMetaIdAccountIdCryptoTypeChainCallsCount += 1
        createSeedExportDataMetaIdAccountIdCryptoTypeChainReceivedArguments = (metaId: metaId, accountId: accountId, cryptoType: cryptoType, chain: chain)
        createSeedExportDataMetaIdAccountIdCryptoTypeChainReceivedInvocations.append((metaId: metaId, accountId: accountId, cryptoType: cryptoType, chain: chain))
        return try createSeedExportDataMetaIdAccountIdCryptoTypeChainClosure.map({ try $0(metaId, accountId, cryptoType, chain) }) ?? createSeedExportDataMetaIdAccountIdCryptoTypeChainReturnValue
    }

}
