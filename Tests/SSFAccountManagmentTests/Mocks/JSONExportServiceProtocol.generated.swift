// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

actor JSONExportServiceProtocolMock: JSONExportServiceProtocol {

    //MARK: - export

    var exportWalletAccountsPasswordCallsCount = 0
    var exportWalletAccountsPasswordCalled: Bool {
        return exportWalletAccountsPasswordCallsCount > 0
    }
    var exportWalletAccountsPasswordReceivedArguments: (wallet: MetaAccountModel, accounts: [ChainAccountInfo], password: String)?
    var exportWalletAccountsPasswordReceivedInvocations: [(wallet: MetaAccountModel, accounts: [ChainAccountInfo], password: String)] = []
    var exportWalletAccountsPasswordReturnValue: [JSONExportData]!
    var exportWalletAccountsPasswordClosure: ((MetaAccountModel, [ChainAccountInfo], String) -> [JSONExportData])?

    func export(wallet: MetaAccountModel, accounts: [ChainAccountInfo], password: String) -> [JSONExportData] {
        exportWalletAccountsPasswordCallsCount += 1
        exportWalletAccountsPasswordReceivedArguments = (wallet: wallet, accounts: accounts, password: password)
        exportWalletAccountsPasswordReceivedInvocations.append((wallet: wallet, accounts: accounts, password: password))
        return exportWalletAccountsPasswordClosure.map({ $0(wallet, accounts, password) }) ?? exportWalletAccountsPasswordReturnValue
    }

    //MARK: - exportAccount

    var exportAccountAddressPasswordChainWalletThrowableError: Error?
    var exportAccountAddressPasswordChainWalletCallsCount = 0
    var exportAccountAddressPasswordChainWalletCalled: Bool {
        return exportAccountAddressPasswordChainWalletCallsCount > 0
    }
    var exportAccountAddressPasswordChainWalletReceivedArguments: (address: String, password: String, chain: ChainModel, wallet: MetaAccountModel)?
    var exportAccountAddressPasswordChainWalletReceivedInvocations: [(address: String, password: String, chain: ChainModel, wallet: MetaAccountModel)] = []
    var exportAccountAddressPasswordChainWalletReturnValue: JSONExportData!
    var exportAccountAddressPasswordChainWalletClosure: ((String, String, ChainModel, MetaAccountModel) throws -> JSONExportData)?

    func exportAccount(address: String, password: String, chain: ChainModel, wallet: MetaAccountModel) throws -> JSONExportData {
        if let error = exportAccountAddressPasswordChainWalletThrowableError {
            throw error
        }
        exportAccountAddressPasswordChainWalletCallsCount += 1
        exportAccountAddressPasswordChainWalletReceivedArguments = (address: address, password: password, chain: chain, wallet: wallet)
        exportAccountAddressPasswordChainWalletReceivedInvocations.append((address: address, password: password, chain: chain, wallet: wallet))
        return try exportAccountAddressPasswordChainWalletClosure.map({ try $0(address, password, chain, wallet) }) ?? exportAccountAddressPasswordChainWalletReturnValue
    }

}
