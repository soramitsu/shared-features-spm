// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFAccountManagment
@testable import SSFModels
@testable import SSFUtils
@testable import RobinHood

class SeedExportServiceProtocolMock: SeedExportServiceProtocol {

    //MARK: - fetchExportDataFor

    var fetchExportDataForWalletAccountsCallsCount = 0
    var fetchExportDataForWalletAccountsCalled: Bool {
        return fetchExportDataForWalletAccountsCallsCount > 0
    }
    var fetchExportDataForWalletAccountsReceivedArguments: (wallet: MetaAccountModel, accounts: [ChainAccountInfo])?
    var fetchExportDataForWalletAccountsReceivedInvocations: [(wallet: MetaAccountModel, accounts: [ChainAccountInfo])] = []
    var fetchExportDataForWalletAccountsReturnValue: [SeedExportData]!
    var fetchExportDataForWalletAccountsClosure: ((MetaAccountModel, [ChainAccountInfo]) -> [SeedExportData])?

    func fetchExportDataFor(wallet: MetaAccountModel, accounts: [ChainAccountInfo]) -> [SeedExportData] {
        fetchExportDataForWalletAccountsCallsCount += 1
        fetchExportDataForWalletAccountsReceivedArguments = (wallet: wallet, accounts: accounts)
        fetchExportDataForWalletAccountsReceivedInvocations.append((wallet: wallet, accounts: accounts))
        return fetchExportDataForWalletAccountsClosure.map({ $0(wallet, accounts) }) ?? fetchExportDataForWalletAccountsReturnValue
    }

    //MARK: - fetchExportDataFor

    var fetchExportDataForAddressChainWalletThrowableError: Error?
    var fetchExportDataForAddressChainWalletCallsCount = 0
    var fetchExportDataForAddressChainWalletCalled: Bool {
        return fetchExportDataForAddressChainWalletCallsCount > 0
    }
    var fetchExportDataForAddressChainWalletReceivedArguments: (address: String, chain: ChainModel, wallet: MetaAccountModel)?
    var fetchExportDataForAddressChainWalletReceivedInvocations: [(address: String, chain: ChainModel, wallet: MetaAccountModel)] = []
    var fetchExportDataForAddressChainWalletReturnValue: SeedExportData!
    var fetchExportDataForAddressChainWalletClosure: ((String, ChainModel, MetaAccountModel) throws -> SeedExportData)?

    func fetchExportDataFor(address: String, chain: ChainModel, wallet: MetaAccountModel) throws -> SeedExportData {
        if let error = fetchExportDataForAddressChainWalletThrowableError {
            throw error
        }
        fetchExportDataForAddressChainWalletCallsCount += 1
        fetchExportDataForAddressChainWalletReceivedArguments = (address: address, chain: chain, wallet: wallet)
        fetchExportDataForAddressChainWalletReceivedInvocations.append((address: address, chain: chain, wallet: wallet))
        return try fetchExportDataForAddressChainWalletClosure.map({ try $0(address, chain, wallet) }) ?? fetchExportDataForAddressChainWalletReturnValue
    }

}
