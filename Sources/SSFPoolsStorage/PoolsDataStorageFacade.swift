import RobinHood
import CoreData
import SSFUtils

enum PoolsDataStorageParams {
    static let modelName = "PoolsDataModel"
    static let modelDirectory: String = "PoolsDataModel.momd"
    static let databaseName = "PoolsDataModel.sqlite"
    public static let momURL = Bundle.main.url(
        forResource: "PoolsDataModel",
        withExtension: "momd"
    )

    static let storageDirectoryURL: URL = {
        let baseURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("CoreData")

        return baseURL!
    }()

    static var storageURL: URL {
        storageDirectoryURL.appendingPathComponent(databaseName)
    }
}

public final class PoolsDataStorageFacade: StorageFacadeProtocol {
    public static let shared = PoolsDataStorageFacade()

    public let databaseService: CoreDataServiceProtocol

    private init() {
        
        let bundle = Bundle(for: PoolsDataStorageFacade.self)

        let omoURL = bundle.url(
            forResource: PoolsDataStorageParams.modelName,
            withExtension: "omo",
            subdirectory: PoolsDataStorageParams.modelDirectory
        )

        let momURL = bundle.url(
            forResource: PoolsDataStorageParams.modelName,
            withExtension: "mom",
            subdirectory: PoolsDataStorageParams.modelDirectory
        )

        let modelURL = omoURL ?? momURL

        let persistentSettings = CoreDataPersistentSettings(
            databaseDirectory: PoolsDataStorageParams.storageDirectoryURL,
            databaseName: PoolsDataStorageParams.databaseName,
            incompatibleModelStrategy: .removeStore
        )

        let configuration = CoreDataServiceConfiguration(
            modelURL: modelURL!,
            storageType: .persistent(settings: persistentSettings)
        )

        databaseService = CoreDataService(configuration: configuration)
    }
    
    public func createRepository<T, U>(
        filter: NSPredicate?,
        sortDescriptors: [NSSortDescriptor],
        mapper: AnyCoreDataMapper<T, U>
    ) -> CoreDataRepository<T, U>
    where T: Identifiable, U: NSManagedObject {
        return CoreDataRepository(
            databaseService: databaseService,
            mapper: mapper,
            filter: filter,
            sortDescriptors: sortDescriptors
        )
    }
}

