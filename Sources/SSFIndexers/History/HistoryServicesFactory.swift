protocol HistoryServicesFactoryProtocol {
    func createSubqueryService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        chainRegistry: ChainRegistryProtocol,
        networkWorker: NetworkWorker
    ) -> HistoryService
    func createSubsquidService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService
    func createGiantsquidService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService
    func createSoraService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService
    func createEtherscanService(networkWorker: NetworkWorker) -> HistoryService
    func createOklinkService(networkWorker: NetworkWorker) -> HistoryService
    func createReefService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService
    func createZetaService(networkWorker: NetworkWorker) -> HistoryService
}

final class HistoryServicesFactory {
    func createSubqueryService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        chainRegistry: ChainRegistryProtocol,
        networkWorker: NetworkWorker
    ) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        let txStorage = try createTxRepository()
        return SubqueryHistoryService(
            txStorage: txStorage,
            chainRegistry: chainRegistry,
            networkWorker: networkWorker
        )
    }
    
    func createSubsquidService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        let txStorage = try Self.createTxRepository()
        return SubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createGiantsquidService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        let txStorage = try Self.createTxRepository()
        return GiantsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createSoraService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService {
        let txStorage = try Self.createTxRepository()
        return SoraSubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createEtherscanService(networkWorker: NetworkWorker) -> HistoryService {
        return EtherscanHistoryService(networkWorker: networkWorker)
    }
    
    func createOklinkService(networkWorker: NetworkWorker) -> HistoryService {
        return OklinkHistoryService(networkWorker: networkWorker)
    }
    
    func createReefService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        networkWorker: NetworkWorker
    ) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        let txStorage = try Self.createTxRepository()
        return ReefSubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createZetaService(networkWorker: NetworkWorker) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return ZetaHistoryService(networkWorker: networkWorker)
    }
}

private extension HistoryServicesFactory {
    private func createTxRepository() throws -> AsyncAnyRepository<TransactionHistoryItem> {
        let repository = try IndexersRepositoryAssemblyDefault().createRepository()
        return AsyncAnyRepository(repository)
    }
}
