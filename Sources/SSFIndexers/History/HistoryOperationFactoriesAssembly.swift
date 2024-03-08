import Foundation
import SSFModels
import RobinHood
import SSFChainRegistry
import SSFNetwork

public enum HistoryError: Error {
    case urlMissing
}

public protocol HistoryService {
    func fetchTransactionHistory(
        chainAsset: ChainAsset,
        address: String,
        filters: [WalletTransactionHistoryFilter],
        pagination: Pagination
    ) async throws -> AssetTransactionPageData?
}

final public class HistoryServiceAssembly {
    public static func createService(
        for chainAsset: ChainAsset
    ) async throws -> HistoryService? {
        let networkWorker = NetworkWorkerDefault()
        switch chainAsset.chain.externalApi?.history?.type {
        case .subquery:
            let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
            let runtimeService = try await chainRegistry.getRuntimeProvider(
                chainId: chainAsset.chain.chainId,
                usedRuntimePaths: [:],
                runtimeItem: nil
            )
            let txStorage = try Self.createTxRepository()
            return SubqueryHistoryService(
                txStorage: txStorage,
                runtimeService: runtimeService,
                networkWorker: networkWorker
            )
        case .subsquid:
            let txStorage = try Self.createTxRepository()
            return SubsquidHistoryService(
                txStorage: txStorage,
                networkWorker: networkWorker
            )
        case .giantsquid:
            let txStorage = try Self.createTxRepository()
            return GiantsquidHistoryService(
                txStorage: txStorage,
                networkWorker: networkWorker
            )
        case .sora:
            let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
            let runtimeService = try await chainRegistry.getRuntimeProvider(
                chainId: chainAsset.chain.chainId,
                usedRuntimePaths: [:],
                runtimeItem: nil
            )
            let txStorage = try Self.createTxRepository()
            return SoraSubsquidHistoryService(
                txStorage: txStorage,
                runtimeService: runtimeService,
                networkWorker: networkWorker
            )
        case .alchemy:
            return AlchemyHistoryService(networkWorker: networkWorker)
        case .etherscan:
            return EtherscanHistoryService(networkWorker: networkWorker)
        case .oklink:
            return OklinkHistoryService(networkWorker: networkWorker)
        case .reef:
            let txStorage = try Self.createTxRepository()
            return ReefSubsquidHistoryService(
                txStorage: txStorage,
                networkWorker: networkWorker
            )
        case .zeta:
            return ZetaHistoryService(networkWorker: networkWorker)
        case .none:
            return nil
        }
    }
    
    private static func createTxRepository() throws -> AsyncAnyRepository<TransactionHistoryItem> {
        let repository = try IndexersRepositoryAssemblyDefault().createRepository()
        return AsyncAnyRepository(repository)
    }
}
