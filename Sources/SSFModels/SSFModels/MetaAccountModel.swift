import Foundation
import RobinHood

public enum FilterOption: String, Codable {
    case hideZeroBalance
    case hiddenSectionOpen
}

public typealias MetaAccountId = String

public struct MetaAccountModel: Equatable, Codable, Identifiable {
    public var identifier: String { name }
    public let metaId: MetaAccountId
    public let name: String
    public let substrateAccountId: Data
    public let substrateCryptoType: UInt8
    public let substratePublicKey: Data
    public let ethereumAddress: Data?
    public let ethereumPublicKey: Data?
    public let chainAccounts: Set<ChainAccountModel>
    public let assetKeysOrder: [String]?
    public let assetFilterOptions: [FilterOption]
    public let canExportEthereumMnemonic: Bool
    public let unusedChainIds: [String]?
    public let selectedCurrency: Currency
    public let chainIdForFilter: ChainModel.Id?
    public let assetsVisibility: [AssetVisibility]
    public let zeroBalanceAssetsHidden: Bool
    public let hasBackup: Bool
    
    public init(metaId: MetaAccountId, 
         name: String,
         substrateAccountId: Data, 
         substrateCryptoType: UInt8,
         substratePublicKey: Data,
         ethereumAddress: Data?,
         ethereumPublicKey: Data?,
         chainAccounts: Set<ChainAccountModel>,
         assetKeysOrder: [String]?,
         assetFilterOptions: [FilterOption],
         canExportEthereumMnemonic: Bool,
         unusedChainIds: [String]?,
         selectedCurrency: Currency,
         chainIdForFilter: ChainModel.Id?,
         assetsVisibility: [AssetVisibility],
         zeroBalanceAssetsHidden: Bool,
         hasBackup: Bool) {
        self.metaId = metaId
        self.name = name
        self.substrateAccountId = substrateAccountId
        self.substrateCryptoType = substrateCryptoType
        self.substratePublicKey = substratePublicKey
        self.ethereumAddress = ethereumAddress
        self.ethereumPublicKey = ethereumPublicKey
        self.chainAccounts = chainAccounts
        self.assetKeysOrder = assetKeysOrder
        self.assetFilterOptions = assetFilterOptions
        self.canExportEthereumMnemonic = canExportEthereumMnemonic
        self.unusedChainIds = unusedChainIds
        self.selectedCurrency = selectedCurrency
        self.chainIdForFilter = chainIdForFilter
        self.assetsVisibility = assetsVisibility
        self.zeroBalanceAssetsHidden = zeroBalanceAssetsHidden
        self.hasBackup = hasBackup
    }
}

extension MetaAccountModel {
    var supportEthereum: Bool {
        ethereumPublicKey != nil || chainAccounts.first(where: { $0.ethereumBased == true }) != nil
    }
}

extension MetaAccountModel {
    public func insertingChainAccount(_ newChainAccount: ChainAccountModel) -> MetaAccountModel {
        var newChainAccounts = chainAccounts.filter {
            $0.chainId != newChainAccount.chainId
        }

        newChainAccounts.insert(newChainAccount)

        return MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: newChainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingEthereumAddress(_ newEthereumAddress: Data?) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: newEthereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingEthereumPublicKey(_ newEthereumPublicKey: Data?) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: newEthereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingName(_ walletName: String) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: walletName,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingAssetKeysOrder(_ newAssetKeysOrder: [String]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: newAssetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingUnusedChainIds(_ newUnusedChainIds: [String]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: newUnusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingCurrency(_ currency: Currency) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: currency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingAssetsFilterOptions(_ options: [FilterOption]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: options,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingChainIdForFilter(_ chainId: ChainModel.Id?) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainId,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    public func replacingAssetsVisibility(_ newAssetsVisibility: [AssetVisibility]) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: newAssetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingZeroBalanceAssetsHidden(_ newZeroBalanceAssetsHidden: Bool) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: newZeroBalanceAssetsHidden,
            hasBackup: hasBackup
        )
    }

    func replacingIsBackuped(_ isBackuped: Bool) -> MetaAccountModel {
        MetaAccountModel(
            metaId: metaId,
            name: name,
            substrateAccountId: substrateAccountId,
            substrateCryptoType: substrateCryptoType,
            substratePublicKey: substratePublicKey,
            ethereumAddress: ethereumAddress,
            ethereumPublicKey: ethereumPublicKey,
            chainAccounts: chainAccounts,
            assetKeysOrder: assetKeysOrder,
            assetFilterOptions: assetFilterOptions,
            canExportEthereumMnemonic: canExportEthereumMnemonic,
            unusedChainIds: unusedChainIds,
            selectedCurrency: selectedCurrency,
            chainIdForFilter: chainIdForFilter,
            assetsVisibility: assetsVisibility,
            zeroBalanceAssetsHidden: zeroBalanceAssetsHidden,
            hasBackup: isBackuped
        )
    }
}
