import Foundation
import RobinHood
import SSFChainConnection
import SSFModels
import SSFRuntimeCodingService
import SSFUtils
import Web3

// sourcery: AutoMockable
public protocol ChainRegistryProtocol: AnyObject {
    func getRuntimeProvider(
        chainId: ChainModel.Id,
        usedRuntimePaths: [String: [String]],
        runtimeItem: RuntimeMetadataItemProtocol?
    ) async throws -> RuntimeProviderProtocol
    func getSubstrateConnection(for chain: ChainModel) async throws -> SubstrateConnection
    func getEthereumConnection(for chain: ChainModel) async throws -> Web3EthConnection
    func getRuntimeProvider(for chainId: ChainModel.Id) async -> RuntimeProviderProtocol?
    func getChain(for chainId: ChainModel.Id) async throws -> ChainModel
    func getChains() async throws -> [ChainModel]
    func getReadySnapshot(
        chainId: ChainModel.Id,
        usedRuntimePaths: [String: [String]],
        runtimeItem: RuntimeMetadataItemProtocol?
    ) async throws -> RuntimeSnapshot
}

public actor ChainRegistry {
    private let runtimeProviderPool: RuntimeProviderPoolProtocol
    private let connectionPool: ConnectionPoolProtocol
    private let chainsDataFetcher: ChainsDataFetcherProtocol
    private let chainsTypesDataFetcher: ChainTypesRemoteDataFercherProtocol
    private let runtimeSyncService: RuntimeSyncServiceProtocol

    private let mutex = NSLock()

    private lazy var readLock = ReaderWriterLock()

    public init(
        runtimeProviderPool: RuntimeProviderPoolProtocol,
        connectionPool: ConnectionPoolProtocol,
        chainsDataFetcher: ChainsDataFetcherProtocol,
        chainsTypesDataFetcher: ChainTypesRemoteDataFercherProtocol,
        runtimeSyncService: RuntimeSyncServiceProtocol
    ) {
        self.runtimeProviderPool = runtimeProviderPool
        self.connectionPool = connectionPool
        self.chainsDataFetcher = chainsDataFetcher
        self.runtimeSyncService = runtimeSyncService
        self.chainsTypesDataFetcher = chainsTypesDataFetcher
        syncUpServices()
    }

    private func syncUpServices() {
        chainsDataFetcher.syncUp()
        chainsTypesDataFetcher.syncUp()
    }
}

// MARK: - ChainRegistryProtocol

extension ChainRegistry: ChainRegistryProtocol {
    public func getRuntimeProvider(
        chainId: ChainModel.Id,
        usedRuntimePaths: [String: [String]],
        runtimeItem: RuntimeMetadataItemProtocol?
    ) async throws -> RuntimeProviderProtocol {
        print("OLOLO getRuntimeProvider")
        let chainModel = try await chainsDataFetcher.getChainModel(for: chainId)
        print("OLOLO chainModel \(chainModel)")
        
        let runtimeMetadataItem: RuntimeMetadataItemProtocol
        if let runtimeItem = runtimeItem {
            runtimeMetadataItem = runtimeItem
        } else {
            let connection = try await connectionPool.setupSubstrateConnection(for: chainModel)
            print("OLOLO connection \(connection)")
            runtimeMetadataItem = try await runtimeSyncService.register(
                chain: chainModel,
                with: connection
            )
            print("OLOLO runtimeMetadataItem \(runtimeMetadataItem)")
        }
        print("OLOLO runtimeMetadataItem final  \(runtimeMetadataItem)")
        let chainTypes = try await chainsTypesDataFetcher.getTypes(for: chainId)
        print("OLOLO chainTypes  \(chainTypes)")
        let runtimeProvider = runtimeProviderPool.setupRuntimeProvider(
            for: runtimeMetadataItem,
            chainTypes: chainTypes,
            usedRuntimePaths: usedRuntimePaths
        )
        print("OLOLO runtimeProvider \(runtimeProvider)")
        return runtimeProvider
    }

    public func getReadySnapshot(
        chainId: ChainModel.Id,
        usedRuntimePaths: [String: [String]],
        runtimeItem: RuntimeMetadataItemProtocol?
    ) async throws -> RuntimeSnapshot {
        let chainModel = try await chainsDataFetcher.getChainModel(for: chainId)

        let runtimeMetadataItem: RuntimeMetadataItemProtocol
        if let runtimeItem = runtimeItem {
            runtimeMetadataItem = runtimeItem
        } else {
            let connection = try await connectionPool.setupSubstrateConnection(for: chainModel)
            runtimeMetadataItem = try await runtimeSyncService.register(
                chain: chainModel,
                with: connection
            )
        }
        let chainTypes = try await chainsTypesDataFetcher.getTypes(for: chainId)
        let readySnaphot = try await runtimeProviderPool.readySnaphot(
            for: runtimeMetadataItem,
            chainTypes: chainTypes,
            usedRuntimePaths: usedRuntimePaths
        )
        return readySnaphot
    }

    public func getSubstrateConnection(for chain: ChainModel) async throws -> SubstrateConnection {
        try await connectionPool.setupSubstrateConnection(for: chain)
    }

    public func getEthereumConnection(
        for chain: SSFModels.ChainModel
    ) async throws -> Web3EthConnection {
        try await connectionPool.setupWeb3EthereumConnection(for: chain)
    }

    public func getRuntimeProvider(for chainId: ChainModel.Id) async -> RuntimeProviderProtocol? {
        readLock.concurrentlyRead { runtimeProviderPool.getRuntimeProvider(for: chainId) }
    }

    public func getChain(for chainId: ChainModel.Id) async throws -> ChainModel {
        try await chainsDataFetcher.getChainModel(for: chainId)
    }

    public func getChains() async throws -> [ChainModel] {
        try await chainsDataFetcher.getChainModels()
    }
}
