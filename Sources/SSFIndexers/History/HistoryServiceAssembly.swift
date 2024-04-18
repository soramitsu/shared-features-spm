import Foundation
import SSFModels
import RobinHood
import SSFChainRegistry
import SSFNetwork

public enum HistoryError: Error {
    case urlMissing
    case missingHistoryType(chainId: ChainModel.Id)
}

public protocol HistoryService: Actor {
    func fetchTransactionHistory(
        chainAsset: ChainAsset,
        address: String,
        filters: [WalletTransactionHistoryFilter],
        pagination: Pagination
    ) async throws -> AssetTransactionPageData?
}

public enum HistoryServiceAssembly {
    public static func createService(
        for chainAsset: ChainAsset
    ) async throws -> HistoryService {
        let factory = HistoryServicesFactory()
        switch chainAsset.chain.externalApi?.history?.type {
        case .subquery:
            let txStorage = try Self.createTxRepository()
            return try factory.createSubqueryService(
                txStorage: txStorage,
                chainRegistry: ChainRegistryAssembly.createDefaultRegistry()
            )
        case .subsquid:
            let txStorage = try Self.createTxRepository()
            return try factory.createSubsquidService(txStorage: txStorage)
        case .giantsquid:
            let txStorage = try Self.createTxRepository()
            return try factory.createGiantsquidService(txStorage: txStorage)
        case .sora:
            let txStorage = try Self.createTxRepository()
            return try factory.createSoraService(txStorage: txStorage)
        case .etherscan:
            return try factory.createEtherscanService()
        case .oklink:
            return try factory.createOklinkService()
        case .reef:
            let txStorage = try Self.createTxRepository()
            return try factory.createReefService(txStorage: txStorage)
        case .zeta:
            return try factory.createZetaService()
        case .none:
            throw HistoryError.missingHistoryType(chainId: chainAsset.chain.chainId)
        }
    }
}

private extension HistoryServiceAssembly {
    private static func createTxRepository() throws -> AsyncAnyRepository<TransactionHistoryItem> {
        let repository = try IndexersRepositoryAssemblyDefault().createRepository()
        return AsyncAnyRepository(repository)
    }
}
