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
    
    func performHotBoot() async
    func performColdBoot() async
    func subscribeToChains() async
}

public actor ChainRegistry {
    private let snapshotHotBootBuilder: SnapshotHotBootBuilderProtocol
    private let runtimeProviderPool: RuntimeProviderPoolProtocol
    private let connectionPools: [any ConnectionPoolProtocol]
    private let chainsDataFetcher: ChainsDataFetcherProtocol
    private let chainsTypesDataFetcher: ChainTypesRemoteDataFercherProtocol
    private let runtimeSyncService: RuntimeSyncServiceProtocol
    private let chainProvider: StreamableProvider<ChainModel>
    private let specVersionSubscriptionFactory: SpecVersionSubscriptionFactoryProtocol
    private let chainsTypesUrl: URL
    private let chainsUrl: URL
    private var chains: [ChainModel] = []
    private(set) var chainsTypesMap: [String: Data] = [:]
    private var runtimeVersionSubscriptions: [ChainModel.Id: SpecVersionSubscriptionProtocol] = [:]
    
    private var substrateConnectionPool: ConnectionPool? {
        connectionPools.first(where: { $0 is ConnectionPool }) as? ConnectionPool
    }

    private var ethereumConnectionPool: EthereumConnectionPool? {
        connectionPools.first(where: { $0 is EthereumConnectionPool }) as? EthereumConnectionPool
    }

    public init(
        runtimeProviderPool: RuntimeProviderPoolProtocol,
        connectionPools: [any ConnectionPoolProtocol],
        chainsDataFetcher: ChainsDataFetcherProtocol,
        chainsTypesDataFetcher: ChainTypesRemoteDataFercherProtocol,
        runtimeSyncService: RuntimeSyncServiceProtocol,
        snapshotHotBootBuilder: SnapshotHotBootBuilderProtocol,
        chainProvider: StreamableProvider<ChainModel>,
        specVersionSubscriptionFactory: SpecVersionSubscriptionFactoryProtocol,
        chainsTypesUrl: URL,
        chainsUrl: URL
    ) {
        self.runtimeProviderPool = runtimeProviderPool
        self.connectionPools = connectionPools
        self.chainsDataFetcher = chainsDataFetcher
        self.runtimeSyncService = runtimeSyncService
        self.chainsTypesDataFetcher = chainsTypesDataFetcher
        self.snapshotHotBootBuilder = snapshotHotBootBuilder
        self.chainProvider = chainProvider
        self.specVersionSubscriptionFactory = specVersionSubscriptionFactory
        self.chainsTypesUrl = chainsTypesUrl
        self.chainsUrl = chainsUrl
        Task { [weak self] in
            await self?.syncUpServices()
        }
    }

    private func syncUpServices() async {
        chainsDataFetcher.syncUp()
        chainsTypesDataFetcher.syncUp()
    }
    
    // MARK: - Private handle subscription methods

    private func handleChainModel(_ changes: [DataProviderChange<ChainModel>]) async {
        guard !changes.isEmpty else {
            return
        }

        await changes.asyncForEach { change in
            do {
                switch change {
                case let .insert(newChain):
                    try await self.handleInsert(newChain)
                case let .update(updatedChain):
                    try await self.handleUpdate(updatedChain)
                case let .delete(chainId):
                    await self.handleDelete(chainId)
                }
            } catch { }
        }
    }
    
    // MARK: - Private DataProviderChange handle methods
    
    private func setupRuntimeVersionSubscription(for chain: ChainModel, connection: ChainConnection) {
        let subscription = specVersionSubscriptionFactory.createSubscription(
            for: chain.chainId,
            connection: connection
        )

        subscription.subscribe()

        runtimeVersionSubscriptions[chain.chainId] = subscription
    }
    
    private func clearRuntimeSubscription(for chainId: ChainModel.Id) {
        if let subscription = runtimeVersionSubscriptions[chainId] {
            subscription.unsubscribe()
        }

        runtimeVersionSubscriptions[chainId] = nil
    }

    private func handleInsert(_ chain: ChainModel) async throws {
        if chain.isEthereum {
            try handleNewEthereumChain(newChain: chain)
        } else {
            try await handleNewSubstrateChain(newChain: chain)
        }
    }

    private func handleUpdate(_ chain: ChainModel) async throws {
        if chain.isEthereum {
            try handleUpdatedEthereumChain(updatedChain: chain)
        } else {
            try await handleUpdatedSubstrateChain(updatedChain: chain)
        }
    }

    private func handleDelete(_ chainId: ChainModel.Id) async {
        guard let removedChain = chains.first(where: { $0.chainId == chainId }) else {
            return
        }

        if removedChain.isEthereum {
            handleDeletedEthereumChain(chainId: chainId)
        } else {
            await handleDeletedSubstrateChain(chainId: chainId)
        }
    }
    
    private func handleNewSubstrateChain(newChain: ChainModel) async throws {
        guard let substrateConnectionPool = self.substrateConnectionPool else {
            return
        }

        let connection = try await substrateConnectionPool.setupConnection(for: newChain)
        let chainTypes = chainsTypesMap[newChain.chainId]

        runtimeProviderPool.setupRuntimeProvider(for: newChain, chainTypes: chainTypes)
        await runtimeSyncService.register(chain: newChain, with: connection)
        setupRuntimeVersionSubscription(for: newChain, connection: connection)

        chains.append(newChain)
    }

    private func handleUpdatedSubstrateChain(updatedChain: ChainModel) async throws {
        guard let substrateConnectionPool = self.substrateConnectionPool else {
            return
        }

        clearRuntimeSubscription(for: updatedChain.chainId)

        let connection = try await substrateConnectionPool.setupConnection(for: updatedChain)
        let chainTypes = chainsTypesMap[updatedChain.chainId]

        runtimeProviderPool.setupRuntimeProvider(for: updatedChain, chainTypes: chainTypes)
        setupRuntimeVersionSubscription(for: updatedChain, connection: connection)

        chains = chains.filter { $0.chainId != updatedChain.chainId }
        chains.append(updatedChain)
    }

    private func handleDeletedSubstrateChain(chainId: ChainModel.Id) async {
        runtimeProviderPool.destroyRuntimeProvider(for: chainId)
        clearRuntimeSubscription(for: chainId)
        await runtimeSyncService.unregister(chainId: chainId)
        chains = chains.filter { $0.chainId != chainId }
    }

    private func resetSubstrateConnection(for chainId: ChainModel.Id) async {
        guard let substrateConnectionPool = self.substrateConnectionPool else {
            return
        }

        await substrateConnectionPool.resetConnection(for: chainId)
    }

    // MARK: - Private ethereum methods

    private func handleNewEthereumChain(newChain: ChainModel) throws {
        guard let ethereumConnectionPool = self.ethereumConnectionPool else {
            return
        }
        chains.append(newChain)
        _ = try ethereumConnectionPool.setupConnection(for: newChain)
    }

    private func handleUpdatedEthereumChain(updatedChain: ChainModel) throws {
        guard let ethereumConnectionPool = self.ethereumConnectionPool else {
            return
        }
        _ = try ethereumConnectionPool.setupConnection(for: updatedChain)
        chains = chains.filter { $0.chainId != updatedChain.chainId }
        chains.append(updatedChain)
    }

    private func handleDeletedEthereumChain(chainId: ChainModel.Id) {
        chains = chains.filter { $0.chainId != chainId }
    }

    private func resetEthereumConnection(for _: ChainModel.Id) {
        // TODO: Reset eth connection
    }
}

// MARK: - ChainRegistryProtocol

extension ChainRegistry: ChainRegistryProtocol {
    public func getRuntimeProvider(
        chainId: SSFModels.ChainModel.Id,
        usedRuntimePaths _: [String: [String]],
        runtimeItem _: SSFModels.RuntimeMetadataItemProtocol?
    ) async throws -> SSFRuntimeCodingService.RuntimeProviderProtocol {
        guard let chain = chains.first(where: { $0.chainId == chainId }) else {
            throw ChainRegistryError.chainUnavailable(chainId: chainId)
        }
        let chainTypes = chainsTypesMap[chainId]

        let runtimeProvider = runtimeProviderPool.setupRuntimeProvider(for: chain, chainTypes: chainTypes)
        return runtimeProvider
    }

    public func getReadySnapshot(
        chainId: SSFModels.ChainModel.Id,
        usedRuntimePaths _: [String: [String]],
        runtimeItem _: SSFModels.RuntimeMetadataItemProtocol?
    ) async throws -> SSFRuntimeCodingService.RuntimeSnapshot {
        guard let runtimeProvider = await getRuntimeProvider(for: chainId) else {
            throw RuntimeProviderError.providerUnavailable
        }
        guard let runtimeSnapshot = runtimeProvider.snapshot else {
            let snapshot = try await runtimeProvider.readySnapshot()
            return snapshot
        }
        return runtimeSnapshot
    }

    public func getSubstrateConnection(for chain: SSFModels.ChainModel) async throws -> SSFChainConnection.SubstrateConnection {
        guard let substrateConnectionPool = self.substrateConnectionPool else {
            throw ChainRegistryError.connectionUnavailable
        }
        let connection = try await substrateConnectionPool.setupConnection(for: chain)
        return connection
    }

    public func getEthereumConnection(for chain: SSFModels.ChainModel) throws -> SSFChainConnection.Web3EthConnection {
        guard let ethereumConnectionPool = self.ethereumConnectionPool else {
            throw ChainRegistryError.connectionUnavailable
        }
        let connection = try ethereumConnectionPool.setupConnection(for: chain)
        return connection
    }

    public func getRuntimeProvider(for chainId: ChainModel.Id) async -> RuntimeProviderProtocol? {
        runtimeProviderPool.getRuntimeProvider(for: chainId)
    }

    public func getChain(for chainId: SSFModels.ChainModel.Id) async throws -> SSFModels.ChainModel {
        let chain = chains.first(where: { $0.chainId == chainId })

        guard let chain else {
            throw ChainRegistryError.chainUnavailable(chainId: chainId)
        }

        return chain
    }

    public func getChains() async throws -> [ChainModel] {
        try await chainsDataFetcher.getChainModels()
    }
    
    public func performColdBoot() async {
        await subscribeToChains()
        await syncUpServices()
    }

    public func performHotBoot() async {
        guard chains.isEmpty else { return }
        snapshotHotBootBuilder.startHotBoot(chainsTypesUrl: chainsTypesUrl, chainsUrl: chainsUrl)
    }
    
    public func subscribeToChains() async {
        let updateClosure: ([DataProviderChange<ChainModel>]) -> Void = { changes in
            Task { [weak self] in
                await self?.handleChainModel(changes)
            }
        }

        let failureClosure: (Error) -> Void = { error in }

        let options = StreamableProviderObserverOptions(
            alwaysNotifyOnRefresh: false,
            waitsInProgressSyncOnAdd: false,
            refreshWhenEmpty: false
        )

        chainProvider.addObserver(
            self,
            deliverOn: DispatchQueue.global(qos: .userInitiated),
            executing: updateClosure,
            failing: failureClosure,
            options: options
        )
    }
}
