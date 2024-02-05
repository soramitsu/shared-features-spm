import Foundation
import RobinHood
import SSFUtils
import SSFPools

final class PoolRepositoryFactory {
    let storageFacade: StorageFacadeProtocol

    init(storageFacade: StorageFacadeProtocol = PoolsDataStorageFacade.shared) {
        self.storageFacade = storageFacade
    }

    func createRepository(
        for filter: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) -> CoreDataRepository<AccountPool, CDAccountPool> {
        return storageFacade.createRepository()
    }
    
    func createRepository(
        for filter: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) -> CoreDataRepository<LiquidityPair, CDLiquidityPair> {
        return storageFacade.createRepository()
    }
}
