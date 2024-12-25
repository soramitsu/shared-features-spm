import Foundation
import RobinHood
import SSFModels
import SSFUtils

public final class ChainRepositoryFactory {
    let storageFacade: StorageFacadeProtocol

    public init(storageFacade: StorageFacadeProtocol = SubstrateDataStorageFacade.shared!) {
        self.storageFacade = storageFacade
    }

    public func createRepository(
        for filter: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) -> CoreDataRepository<ChainModel, CDChain> {
        let mapper = ChainModelMapper()
        return storageFacade.createRepository(
            filter: filter,
            sortDescriptors: sortDescriptors,
            mapper: AnyCoreDataMapper(mapper)
        )
    }

    public func createAsyncRepository(
        for filter: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) -> AsyncCoreDataRepositoryDefault<ChainModel, CDChain> {
        let mapper = ChainModelMapper()
        return storageFacade.createAsyncRepository(
            filter: filter,
            sortDescriptors: sortDescriptors,
            mapper: AnyCoreDataMapper(mapper)
        )
    }
}
