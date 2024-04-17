import Foundation
import SSFModels
import RobinHood
import SSFChainRegistry
import SSFNetwork

public enum HistoryError: Error {
    case urlMissing
    case missingHistoryType(chainId: ChainModel.Id)
}

public protocol HistoryService {
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
        let networkWorker = NetworkWorkerDefault()
        switch chainAsset.chain.externalApi?.history?.type {
        case .subquery:
            let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
            let txStorage = try Self.createTxRepository()
            return SubqueryHistoryService(
                txStorage: txStorage,
                chainRegistry: chainRegistry,
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
            let txStorage = try Self.createTxRepository()
            return SoraSubsquidHistoryService(
                txStorage: txStorage,
                networkWorker: networkWorker
            )
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
            throw HistoryError.missingHistoryType(chainId: chainAsset.chain.chainId)
        }
    }
}
