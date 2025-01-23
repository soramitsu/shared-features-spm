import Foundation
import RobinHood
import TonSwift

public typealias MetaAccountId = String

public struct MetaAccountModel: Equatable, Codable, Identifiable {
    public var identifier: String { metaId }

    public let metaId: MetaAccountId
    public let name: String
    public let ecosystem: WalletEcosystem

    public let chainAccounts: Set<ChainAccountModel>
    public let assetKeysOrder: [String]?
    public let canExportEthereumMnemonic: Bool
    public let unusedChainIds: [String]?
    public let selectedCurrency: Currency
    public let networkManagmentFilter: String?
    public let assetsVisibility: [AssetVisibility]
    public let hasBackup: Bool
    public let favouriteChainIds: [ChainModel.Id]
    
    public init(
        metaId: MetaAccountId,
        name: String,
        ecosystem: WalletEcosystem,
        chainAccounts: Set<ChainAccountModel>,
        assetKeysOrder: [String]?,
        canExportEthereumMnemonic: Bool,
        unusedChainIds: [String]?,
        selectedCurrency: Currency,
        networkManagmentFilter: String?,
        assetsVisibility: [AssetVisibility],
        hasBackup: Bool,
        favouriteChainIds: [ChainModel.Id]
    ) {
        self.metaId = metaId
        self.name = name
        self.ecosystem = ecosystem
        self.chainAccounts = chainAccounts
        self.assetKeysOrder = assetKeysOrder
        self.canExportEthereumMnemonic = canExportEthereumMnemonic
        self.unusedChainIds = unusedChainIds
        self.selectedCurrency = selectedCurrency
        self.networkManagmentFilter = networkManagmentFilter
        self.assetsVisibility = assetsVisibility
        self.hasBackup = hasBackup
        self.favouriteChainIds = favouriteChainIds
    }
}

public extension MetaAccountModel {
    var supportEthereum: Bool {
        ecosystem.ethereumPublicKey != nil || chainAccounts.first(where: { $0.ecosystem == .ethereum || $0.ecosystem == .ethereum }) != nil
    }
    
    func isVisible(chainAsset: ChainAsset) -> Bool {
        assetsVisibility.first(where: { $0.assetId == chainAsset.identifier })?.hidden == false
    }
}

// MARK: - Account request

public struct ChainAccountRequest {
    public let chainId: ChainModel.Id
    public let addressPrefix: UInt16
    public let ecosystem: Ecosystem
    public let accountId: AccountId?
    
    public init(
        chainId: ChainModel.Id,
        addressPrefix: UInt16,
        ecosystem: Ecosystem,
        accountId: AccountId?
    ) {
        self.chainId = chainId
        self.addressPrefix = addressPrefix
        self.ecosystem = ecosystem
        self.accountId = accountId
    }
}

// MARK: - Replacing

public extension MetaAccountModel {
    func insertingChainAccount(_ newChainAccount: ChainAccountModel) -> MetaAccountModel {
        var newChainAccounts = chainAccounts.filter {
            $0.chainId != newChainAccount.chainId
        }

        newChainAccounts.insert(newChainAccount)

        return MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: newChainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

//    func replacingEthereumAddress(_ newEthereumAddress: Data?) -> MetaAccountModel {
//        MetaAccountModel(
//            metaId: metaId,
//            name: name,
//            substrateAccountId: substrateAccountId,
//            substrateCryptoType: substrateCryptoType,
//            substratePublicKey: substratePublicKey,
//            ethereumAddress: newEthereumAddress,
//            ethereumPublicKey: ethereumPublicKey,
//            tonAddress: tonAddress,
//            tonPublicKey: tonPublicKey,
//            tonContractVersion: tonContractVersion,
//            chainAccounts: chainAccounts,
//            assetKeysOrder: assetKeysOrder,
//            canExportEthereumMnemonic: canExportEthereumMnemonic,
//            unusedChainIds: unusedChainIds,
//            selectedCurrency: selectedCurrency,
//            networkManagmentFilter: networkManagmentFilter,
//            assetsVisibility: assetsVisibility,
//            hasBackup: hasBackup,
//            favouriteChainIds: favouriteChainIds
//        )
//    }
//    
//    func replacingTon(
//        tonPublicKey: Data?,
//        tonAddress: TonSwift.Address?,
//        tonContractVersion: TonContractVersion?
//    ) -> MetaAccountModel {
//        MetaAccountModel(
//            metaId: metaId,
//            name: name,
//            substrateAccountId: substrateAccountId,
//            substrateCryptoType: substrateCryptoType,
//            substratePublicKey: substratePublicKey,
//            ethereumAddress: ethereumAddress,
//            ethereumPublicKey: ethereumPublicKey,
//            tonAddress: tonAddress,
//            tonPublicKey: tonPublicKey,
//            tonContractVersion: tonContractVersion,
//            chainAccounts: chainAccounts,
//            assetKeysOrder: assetKeysOrder,
//            canExportEthereumMnemonic: canExportEthereumMnemonic,
//            unusedChainIds: unusedChainIds,
//            selectedCurrency: selectedCurrency,
//            networkManagmentFilter: networkManagmentFilter,
//            assetsVisibility: assetsVisibility,
//            hasBackup: hasBackup,
//            favouriteChainIds: favouriteChainIds
//        )
//    }
//
//    func replacingEthereumPublicKey(_ newEthereumPublicKey: Data?) -> MetaAccountModel {
//        MetaAccountModel(
//            metaId: metaId,
//            name: name,
//            substrateAccountId: substrateAccountId,
//            substrateCryptoType: substrateCryptoType,
//            substratePublicKey: substratePublicKey,
//            ethereumAddress: ethereumAddress,
//            ethereumPublicKey: newEthereumPublicKey,
//            tonAddress: tonAddress,
//            tonPublicKey: tonPublicKey,
//            tonContractVersion: tonContractVersion,
//            chainAccounts: chainAccounts,
//            assetKeysOrder: assetKeysOrder,
//            canExportEthereumMnemonic: canExportEthereumMnemonic,
//            unusedChainIds: unusedChainIds,
//            selectedCurrency: selectedCurrency,
//            networkManagmentFilter: networkManagmentFilter,
//            assetsVisibility: assetsVisibility,
//            hasBackup: hasBackup,
//            favouriteChainIds: favouriteChainIds
//        )
//    }

    func replacingName(_ walletName: String) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: walletName,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingAssetKeysOrder(_ newAssetKeysOrder: [String]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: newAssetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingUnusedChainIds(_ newUnusedChainIds: [String]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: newUnusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingCurrency(_ currency: Currency) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: currency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingNetworkManagmentFilter(_ identifire: String) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: identifire,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingAssetsVisibility(_ newAssetsVisibility: [AssetVisibility]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: newAssetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingIsBackuped(_ isBackuped: Bool) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: isBackuped,
            favouriteChainIds: favouriteChainIds
        )
    }

    func replacingFavoutites(_ favouriteChainIds: [ChainModel.Id]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            ecosystem: ecosystem,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            networkManagmentFilter: networkManagmentFilter,
            assetsVisibility: assetsVisibility,
            hasBackup: hasBackup,
            favouriteChainIds: favouriteChainIds
        )
    }
}
