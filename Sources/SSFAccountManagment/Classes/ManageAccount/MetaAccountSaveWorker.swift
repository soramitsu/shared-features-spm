import Foundation
import SSFModels
import SSFUtils
import RobinHood
import SSFAccountManagmentStorage

public protocol AccountManagementWorkerProtocol {
    func save(
        account: MetaAccountModel,
        selectedWallet: PersistentValueSettings<MetaAccountModel>
    ) async -> Result<MetaAccountModel, Error>
    
    func deleteAll() async -> Result<Void, Error>
}

public final class AccountManagementWorker: AccountManagementWorkerProtocol {
    
    private let metaAccountrepository: AnyDataProviderRepository<MetaAccountModel>
    private let managedAccountRepository: AnyDataProviderRepository<ManagedMetaAccountModel>
    private let operationManager: OperationManagerProtocol
    
    public init(
        accountRepositoryFactory: AccountRepositoryFactoryProtocol = AccountRepositoryFactory(storageFacade: UserDataStorageFacade.shared),
        operationManager: OperationManagerProtocol = OperationManagerFacade.sharedManager
    ) {
        self.operationManager = operationManager
        self.metaAccountrepository = accountRepositoryFactory.createMetaAccountRepository(for: nil, sortDescriptors: [])
        self.managedAccountRepository = accountRepositoryFactory.createManagedMetaAccountRepository(
            for: nil,
            sortDescriptors: [ NSSortDescriptor.accountsByOrder ])
    }
    
    public func save(
        account: MetaAccountModel,
        selectedWallet: PersistentValueSettings<MetaAccountModel>
    ) async -> Result<MetaAccountModel, Error> { //throws
        let saveOperation = metaAccountrepository.saveOperation { [ account ] } _: { [] }
        operationManager.enqueue(operations: [ saveOperation ], in: .transient)
        
        return await withUnsafeContinuation({ continuation in
            saveOperation.completionBlock = {
               selectedWallet.performSave(value: account) { result in
                   continuation.resume(returning: result)
                }
            }
        })
    }
    
    public func deleteAll() async -> Result<Void, Error> {
        let deleteAllOperation = managedAccountRepository.deleteAllOperation()
        operationManager.enqueue(operations: [ deleteAllOperation ], in: .transient)
        
        return await withUnsafeContinuation({ continuation in
            deleteAllOperation.completionBlock = {
                continuation.resume(returning: .success(()))
            }
        })
    }
}
