import Foundation
import SSFNetwork
import SSFUtils

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

        let runtimeSyncService = RuntimeSyncService(dataOperationFactory: NetworkOperationFactory())

        let chainRegistry = ChainRegistry(
            runtimeProviderPool: RuntimeProviderPool(),
            connectionPool: ConnectionPool(),
            chainsDataFetcher: chainsDataFetcher,
            chainsTypesDataFetcher: chainsTypesDataFetcher,
            runtimeSyncService: runtimeSyncService
        )

        return chainRegistry
    }
}
