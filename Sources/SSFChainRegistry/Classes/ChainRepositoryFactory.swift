import Foundation
import RobinHood
import SSFModels
import SSFUtils
import SSFAssetManagmentStorage

final class ChainRepositoryFactory {
    let storageFacade: StorageFacadeProtocol

    init(storageFacade: StorageFacadeProtocol) {
        self.storageFacade = storageFacade
    }

    func createRepository(
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

    func createAsyncRepository(
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
