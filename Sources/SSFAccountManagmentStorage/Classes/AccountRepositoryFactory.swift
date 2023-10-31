import Foundation
import IrohaCrypto
import RobinHood
import SSFModels
import SSFUtils

public protocol AccountRepositoryFactoryProtocol {
    // TODO: remove
    @available(*, deprecated, message: "Use createMetaAccountRepository(for filter:, sortDescriptors:) instead")
    func createRepository() -> AnyDataProviderRepository<MetaAccountModel>

    // TODO: remove
    func createAccountRepository(for networkType: SNAddressType) -> AnyDataProviderRepository<MetaAccountModel>

    func createMetaAccountRepository(
        for filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]
    ) -> AnyDataProviderRepository<MetaAccountModel>

    func createManagedMetaAccountRepository(
        for filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]
    ) -> AnyDataProviderRepository<ManagedMetaAccountModel>
}

public final class AccountRepositoryFactory: AccountRepositoryFactoryProtocol {
    let storageFacade: StorageFacadeProtocol

    public init(storageFacade: StorageFacadeProtocol) {
        self.storageFacade = storageFacade
    }

    public func createRepository() -> AnyDataProviderRepository<MetaAccountModel> {
        Self.createRepository(for: storageFacade)
    }

    // TODO: remove
    public func createAccountRepository(
        for _: SNAddressType
    ) -> AnyDataProviderRepository<MetaAccountModel> {
        Self.createRepository(for: storageFacade)
    }

    public func createMetaAccountRepository(
        for filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]
    ) -> AnyDataProviderRepository<MetaAccountModel> {
        let mapper = MetaAccountMapper()

        let repository = storageFacade.createRepository(
            filter: filter,
            sortDescriptors: sortDescriptors,
            mapper: AnyCoreDataMapper(mapper)
        )

        return AnyDataProviderRepository(repository)
    }

    public func createManagedMetaAccountRepository(
        for filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]
    ) -> AnyDataProviderRepository<ManagedMetaAccountModel> {
        let mapper = ManagedMetaAccountMapper()

        let repository = storageFacade.createRepository(
            filter: filter,
            sortDescriptors: sortDescriptors,
            mapper: AnyCoreDataMapper(mapper)
        )

        return AnyDataProviderRepository(repository)
    }
}

extension AccountRepositoryFactory {
    static func createRepository(
        for storageFacade: StorageFacadeProtocol = UserDataStorageFacade.shared
    ) -> AnyDataProviderRepository<MetaAccountModel> {
        let mapper = MetaAccountMapper()
        let repository = storageFacade.createRepository(mapper: AnyCoreDataMapper(mapper))

        return AnyDataProviderRepository(repository)
    }
}
