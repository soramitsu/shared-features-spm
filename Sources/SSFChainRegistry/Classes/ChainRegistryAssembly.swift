import Foundation
import SSFNetwork
import SSFUtils
import RobinHood
import SSFModels
import SSFAssetManagmentStorage
import SSFChainConnection
import SSFRuntimeCodingService

public enum ChainRegistryAssembly {
    public static func createDefaultRegistry(
        chainsUrl: URL = ApplicationSourcesImpl.shared.chainsSourceUrl,
        chainTypesUrls: URL = ApplicationSourcesImpl.shared.chainTypesSourceUrl
    ) -> ChainRegistryProtocol {
        let chainsDataFetcher = ChainsDataFetcher(
            chainsUrl: chainsUrl,
            operationQueue: OperationQueue(),
            dataFetchFactory: NetworkOperationFactory()
        )

        let chainsTypesDataFetcher = ChainTypesRemoteDataFercher(
            url: chainTypesUrls,
            dataOperationFactory: NetworkOperationFactory(),
            operationQueue: OperationQueue()
        )
        
        let repositoryFacade = SubstrateDataStorageFacade()!
        let runtimeMetadataRepository: CoreDataRepository<RuntimeMetadataItem, CDRuntimeMetadataItem> =
            repositoryFacade.createRepository()
        let chainRepositoryFactory = ChainRepositoryFactory(storageFacade: repositoryFacade)
        let chainRepository = chainRepositoryFactory.createRepository()
        let chainProvider = createChainProvider(from: repositoryFacade, chainRepository: chainRepository)
        
        let filesOperationFactory = createFilesOperationFactory()
        let dataFetchOperationFactory = DataOperationFactory()
        
        let runtimeProviderFactory = RuntimeProviderFactory(
            fileOperationFactory: filesOperationFactory,
            repository: AnyDataProviderRepository(runtimeMetadataRepository),
            dataOperationFactory: dataFetchOperationFactory,
            operationQueue: OperationManagerFacade.runtimeBuildingQueue
        )
        
        let runtimeProviderPool = RuntimeProviderPool(runtimeProviderFactory: runtimeProviderFactory)
        
        let snapshotHotBootBuilder = SnapshotHotBootBuilder(
            runtimeProviderPool: runtimeProviderPool,
            chainRepository: AnyDataProviderRepository(chainRepository),
            filesOperationFactory: filesOperationFactory,
            runtimeItemRepository: AnyDataProviderRepository(runtimeMetadataRepository),
            dataOperationFactory: NetworkOperationFactory(),
            operationQueue: OperationManagerFacade.runtimeBuildingQueue
        )

        let runtimeSyncService = RuntimeSyncService(dataOperationFactory: NetworkOperationFactory())
        
        let substrateConnectionPool = ConnectionPool(
            connectionFactory: ConnectionFactory()
        )
        let ethereumConnectionPool = EthereumConnectionPool()
        
        let specVersionSubscriptionFactory = SpecVersionSubscriptionFactory(
            runtimeSyncService: runtimeSyncService
        )

        let chainRegistry = ChainRegistry(
            runtimeProviderPool: runtimeProviderPool,
            connectionPools: [substrateConnectionPool, ethereumConnectionPool],
            chainsDataFetcher: chainsDataFetcher,
            chainsTypesDataFetcher: chainsTypesDataFetcher,
            runtimeSyncService: runtimeSyncService,
            snapshotHotBootBuilder: snapshotHotBootBuilder,
            chainProvider: chainProvider,
            specVersionSubscriptionFactory: specVersionSubscriptionFactory,
            chainsTypesUrl: chainTypesUrls,
            chainsUrl: chainsUrl
        )

        return chainRegistry
    }
    
    private static func createChainProvider(
        from repositoryFacade: StorageFacadeProtocol,
        chainRepository: CoreDataRepository<ChainModel, CDChain>
    ) -> StreamableProvider<ChainModel> {
        let chainObserver = CoreDataContextObservable(
            service: repositoryFacade.databaseService,
            mapper: chainRepository.dataMapper,
            predicate: { _ in true }
        )

        chainObserver.start { error in
        }

        return StreamableProvider(
            source: AnyStreamableSource(EmptyStreamableSource<ChainModel>()),
            repository: AnyDataProviderRepository(chainRepository),
            observable: AnyDataProviderRepositoryObservable(chainObserver),
            operationManager: OperationManagerFacade.sharedManager
        )
    }
    
    private static func createFilesOperationFactory() -> RuntimeFilesOperationFactoryProtocol {
        let topDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ??
            FileManager.default.temporaryDirectory
        let runtimeDirectory = topDirectory.appendingPathComponent("runtime").path
        return RuntimeFilesOperationFactory(
            repository: FileRepository(),
            directoryPath: runtimeDirectory
        )
    }
}
