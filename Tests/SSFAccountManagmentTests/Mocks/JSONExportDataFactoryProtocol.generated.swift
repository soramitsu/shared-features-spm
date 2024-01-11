// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class JSONExportDataFactoryProtocolMock: JSONExportDataFactoryProtocol {

    //MARK: - createJSONExportData

    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashThrowableError: Error?
    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashCallsCount = 0
    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashCalled: Bool {
        return createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashCallsCount > 0
    }
    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashReceivedArguments: (metaId: MetaAccountId, accountId: AccountId?, chainAccount: ChainAccountResponse, chain: ChainModel, password: String, address: String, genesisHash: String?)?
    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashReceivedInvocations: [(metaId: MetaAccountId, accountId: AccountId?, chainAccount: ChainAccountResponse, chain: ChainModel, password: String, address: String, genesisHash: String?)] = []
    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashReturnValue: JSONExportData?
    var createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashClosure: ((MetaAccountId, AccountId?, ChainAccountResponse, ChainModel, String, String, String?) throws -> JSONExportData?)?

    func createJSONExportData(metaId: MetaAccountId, accountId: AccountId?, chainAccount: ChainAccountResponse, chain: ChainModel, password: String, address: String, genesisHash: String?) throws -> JSONExportData? {
        if let error = createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashThrowableError {
            throw error
        }
        createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashCallsCount += 1
        createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashReceivedArguments = (metaId: metaId, accountId: accountId, chainAccount: chainAccount, chain: chain, password: password, address: address, genesisHash: genesisHash)
        createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashReceivedInvocations.append((metaId: metaId, accountId: accountId, chainAccount: chainAccount, chain: chain, password: password, address: address, genesisHash: genesisHash))
        return try createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashClosure.map({ try $0(metaId, accountId, chainAccount, chain, password, address, genesisHash) }) ?? createJSONExportDataMetaIdAccountIdChainAccountChainPasswordAddressGenesisHashReturnValue
    }

}
