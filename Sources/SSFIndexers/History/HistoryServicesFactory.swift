import RobinHood
import SSFChainRegistry
import SSFNetwork

protocol HistoryServicesFactoryProtocol {
    func createSubqueryService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        chainRegistry: ChainRegistryProtocol
    ) -> HistoryService
    func createSubsquidService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService
    func createGiantsquidService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService
    func createSoraService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService
    func createEtherscanService() -> HistoryService
    func createOklinkService() -> HistoryService
    func createReefService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService
    func createZetaService() -> HistoryService
}

final class HistoryServicesFactory {
    func createSubqueryService(
        txStorage: AsyncAnyRepository<TransactionHistoryItem>,
        chainRegistry: ChainRegistryProtocol
    ) throws -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return SubqueryHistoryService(
            txStorage: txStorage,
            chainRegistry: chainRegistry,
            networkWorker: networkWorker
        )
    }
    
    func createSubsquidService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return SubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createGiantsquidService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return GiantsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createSoraService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return SoraSubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createEtherscanService() -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return EtherscanHistoryService(networkWorker: networkWorker)
    }
    
    func createOklinkService() -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return OklinkHistoryService(networkWorker: networkWorker)
    }
    
    func createReefService(txStorage: AsyncAnyRepository<TransactionHistoryItem>) -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return ReefSubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
    
    func createZetaService() -> HistoryService {
        let networkWorker = NetworkWorkerDefault()
        return ZetaHistoryService(networkWorker: networkWorker)
    }
}
