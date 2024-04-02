import Foundation
import RobinHood
import SSFUtils
import SSFPools

public final class PoolRepositoryFactory {
    private let storageFacade: StorageFacadeProtocol

    public init(storageFacade: StorageFacadeProtocol) {
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
