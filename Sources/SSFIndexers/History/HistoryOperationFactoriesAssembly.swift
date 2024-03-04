import Foundation
import SSFModels
import RobinHood
import SSFChainRegistry

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
        for chainAsset: ChainAsset,
        with txStorage: AsyncAnyRepository<TransactionHistoryItem>
    ) async throws -> HistoryService? {
        switch chainAsset.chain.externalApi?.history?.type {
        case .subquery:
            let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
            let runtimeService = try await chainRegistry.getRuntimeProvider(
                chainId: chainAsset.chain.chainId,
                usedRuntimePaths: [:],
                runtimeItem: nil
            )
            return SubqueryHistoryService(
                txStorage: txStorage,
                runtimeService: runtimeService
            )
        case .subsquid:
            return SubsquidHistoryService(txStorage: txStorage)
        case .giantsquid:
            return GiantsquidHistoryService(txStorage: txStorage)
        case .sora:
            let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
            let runtimeService = try await chainRegistry.getRuntimeProvider(
                chainId: chainAsset.chain.chainId,
                usedRuntimePaths: [:],
                runtimeItem: nil
            )
            return SoraSubsquidHistoryService(
                txStorage: txStorage,
                runtimeService: runtimeService
            )
        case .alchemy:
            return AlchemyHistoryService()
        case .etherscan:
            return EtherscanHistoryService()
        case .oklink:
            return OklinkHistoryService()
        case .reef:
            return ReefSubsquidHistoryService(txStorage: txStorage)
        case .zeta:
            return ZetaHistoryService()
        case .none:
            return nil
        }
    }
}
