import RobinHood
import Foundation
import SSFModels
import SSFUtils
import SSFAccountManagmentStorage

public enum AccountManagerServiceError: Error {
    case unexpected
}

public protocol AccountManageble {
    func getCurrentAccount() -> MetaAccountModel?
    func update(visible: Bool, for chainAsset: ChainAsset) async -> Result<MetaAccountModel, Error>
    func logout() async -> Result<Void, Error>
}

public final class AccountManagementService {
    private let operationQueue: OperationQueue = OperationManagerFacade.sharedDefaultQueue
    private let selectedWallet: PersistentValueSettings<MetaAccountModel>
    private let accountManagementWorker: AccountManagementWorkerProtocol
    
    public init(
        accountManagementWorker: AccountManagementWorkerProtocol = AccountManagementWorker(),
        selectedWallet: PersistentValueSettings<MetaAccountModel>
    ) {
        self.selectedWallet = selectedWallet
        self.accountManagementWorker = accountManagementWorker
    }
}

extension AccountManagementService: AccountManageble {
    public func getCurrentAccount() -> MetaAccountModel? {
        return selectedWallet.value
    }
    
    public func update(visible: Bool, for chainAsset: ChainAsset) async -> Result<MetaAccountModel, Error> {
        let accountRequest = chainAsset.chain.accountRequest()
        
        guard let wallet = selectedWallet.value, let accountId = wallet.fetch(for: accountRequest)?.accountId else {
            return .failure(AccountManagerServiceError.unexpected)
        }
        
        let chainAssetKey = chainAsset.uniqueKey(accountId: accountId)

        var assetsVisibility = wallet.assetsVisibility.filter { $0.assetId != chainAssetKey }

        let assetVisibility = AssetVisibility(assetId: chainAssetKey, visible: visible)
        assetsVisibility.append(assetVisibility)

        let updatedAccount = wallet.replacingAssetsVisibility(assetsVisibility)
        
        return await accountManagementWorker.save(account: updatedAccount, selectedWallet: selectedWallet)
    }
    
    public func logout() async -> Result<Void, Error> {
        return await accountManagementWorker.deleteAll()
    }
}
