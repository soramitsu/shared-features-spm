import Foundation
import SSFNetwork
import SSFUtils

final public class ChainRegistryAssembly {
    public static func createDefaultRegistry() -> ChainRegistryProtocol {
        let chainSyncService = ChainSyncService(
            chainsUrl: ApplicationSourcesImpl.shared.chainsSourceUrl,
            operationQueue: OperationQueue(),
            dataFetchFactory: NetworkOperationFactory()
        )
        
        let chainsTypesSyncService = ChainsTypesSyncService(
            url: ApplicationSourcesImpl.shared.chainTypesSourceUrl,
            dataOperationFactory: NetworkOperationFactory(),
            operationQueue: OperationQueue()
        )
        
        let runtimeSyncService = RuntimeSyncService(dataOperationFactory: NetworkOperationFactory())

        let chainRegistry = ChainRegistry(
            runtimeProviderPool: RuntimeProviderPool(),
            connectionPool: ConnectionPool(),
            chainSyncService: chainSyncService,
            chainsTypesSyncService: chainsTypesSyncService,
            runtimeSyncService: runtimeSyncService
        )

        return chainRegistry
    }
}
