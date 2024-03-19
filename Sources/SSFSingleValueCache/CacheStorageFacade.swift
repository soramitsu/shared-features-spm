import Foundation
import RobinHood
import CoreData

public protocol StorageFacade: AnyObject {
    var databaseService: CoreDataServiceProtocol { get }

    func createAsyncRepository<T, U>(
        filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        mapper: AnyCoreDataMapper<T, U>
    ) -> AsyncCoreDataRepositoryDefault<T, U>
    
    func createRepository<T, U>(
        filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        mapper: AnyCoreDataMapper<T, U>
    ) -> CoreDataRepository<T, U> where T: Identifiable, U: NSManagedObject
}

public final class CacheStorageFacade: StorageFacade {
    public let databaseService: CoreDataServiceProtocol

    public init() throws {
        guard
            let baseURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first?.appendingPathComponent("CoreData"),
            let modelURL = Bundle.module.url(
                forResource: "CacheDataModel",
                withExtension: "momd"
            )
        else {
            throw CacheStorageFacadeError.coreDataUrlMissed
        }
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        let persistentSettings = CoreDataPersistentSettings(
            databaseDirectory: baseURL,
            databaseName: "CacheDataModel.sqlite",
            incompatibleModelStrategy: .removeStore,
            options: options
        )
        
        let configuration = CoreDataServiceConfiguration(
            modelURL: modelURL,
            storageType: .persistent(settings: persistentSettings)
        )
        
        databaseService = CoreDataService(configuration: configuration)
    }

    public func createAsyncRepository<T, U>(
        filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        mapper: AnyCoreDataMapper<T, U>
    ) -> AsyncCoreDataRepositoryDefault<T, U> {
        AsyncCoreDataRepositoryDefault(
            databaseService: databaseService,
            mapper: mapper,
            filter: filter,
            sortDescriptors: sortDescriptors
        )
    }
    
    public func createRepository<T, U>(
        filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        mapper: AnyCoreDataMapper<T, U>
    ) -> CoreDataRepository<T, U> where T: Identifiable, U: NSManagedObject {
        CoreDataRepository(
            databaseService: databaseService,
            mapper: mapper,
            filter: filter,
            sortDescriptors: sortDescriptors
        )
    }
}

public enum CacheStorageFacadeError: Error {
    case coreDataUrlMissed
}
