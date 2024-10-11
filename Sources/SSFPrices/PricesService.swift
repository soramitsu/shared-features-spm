import Foundation
import SSFModels
import RobinHood

protocol PricesServiceProtocol {
    func setup()
    func subscribeForPrices(listener: PricesServiceListener)
}

protocol PricesServiceListener {
    func didUpdatePrices(for chainAssets: [ChainAsset])
}

final class PricesService: PricesServiceProtocol {
    static let shared: PricesServiceProtocol = PricesService.create()
    private let priceLocalSubscriber = PriceLocalStorageSubscriberImpl.shared
    private let chainRepository: AnyDataProviderRepository<ChainModel>
    private let walletRepository: AnyDataProviderRepository<MetaAccountModel>
    private let operationQueue: OperationQueue
    private let logger: Logger
    private var pricesProvider: AnySingleValueProvider<[PriceData]>?
    private var chainAssets: [ChainAsset] = []
    private var currencies: [SSFModels.Currency] = []
    private var lastRequestDate: Date?
    private var listeners: [PricesServiceListener] = []

    private init(
        chainRepository: AnyDataProviderRepository<ChainModel>,
        walletRepository: AnyDataProviderRepository<MetaAccountModel>,
        operationQueue: OperationQueue,
        logger: Logger
    ) {
        self.chainRepository = chainRepository
        self.walletRepository = walletRepository
        self.operationQueue = operationQueue
        self.logger = logger
    }

    func setup() {
        let walletsOperation = walletRepository.fetchAllOperation(with: RepositoryFetchOptions())
        let chainsOperation = chainRepository.fetchAllOperation(with: RepositoryFetchOptions())
        let subscribeOperation = ClosureOperation { [weak self] in
            let wallets = try walletsOperation.extractNoCancellableResultData()
            let currencies = wallets.compactMap { $0.selectedCurrency }.uniq(predicate: { $0.id })

            let chains = try chainsOperation.extractNoCancellableResultData()
            let chainAssets = chains.map(\.chainAssets).reduce([], +).uniq(predicate: { $0.chainAssetId })

            self?.observePrices(for: chainAssets, currencies: currencies)
        }
        subscribeOperation.addDependency(walletsOperation)
        subscribeOperation.addDependency(chainsOperation)
        operationQueue.addOperations([subscribeOperation, walletsOperation, chainsOperation], waitUntilFinished: false)
    }

    func subscribeForPrices(listener: PricesServiceListener) {
        if !listeners.contains(listener) {
            listeners.append(listener)
        }
        pricesProvider?.refresh()
    }
}

extension PricesService: PriceLocalSubscriptionHandler {
    func handlePrice(
        result _: Result<PriceData?, Error>,
        chainAsset _: ChainAsset
    ) {}

    func handlePrices(result: Result<[PriceData], Error>, for chainAssets: [ChainAsset]) {
        switch result {
        case let .success(priceDatas):
            handle(prices: priceDatas, for: chainAssets)
        case let .failure(error):
            handle(error: error)
        }
    }
}

extension PricesService: PriceDataSource {
    func getPrices() async -> [ChainAsset] {
        self.forceUpdate = true
        self.pricesProvider?.refresh()
    }
}

private extension PricesService {
    static func create() -> PricesServiceProtocol {
        let chainRepository = ChainRepositoryFactory().createRepository()
        let accountRepositoryFactory = AccountRepositoryFactory(storageFacade: UserDataStorageFacade.shared)
        let walletRepository = accountRepositoryFactory.createMetaAccountRepository(for: nil, sortDescriptors: [])
        return PricesService(
            chainRepository: AnyDataProviderRepository(chainRepository),
            walletRepository: AnyDataProviderRepository(walletRepository),
            operationQueue: OperationQueue(),
            logger: Logger.shared
        )
    }

    func observePrices(for chainAssets: [SSFModels.ChainAsset], currencies: [SSFModels.Currency]) {
        let oldAssets = self.chainAssets
        let uniqueAssets = chainAssets.filter { newAsset in
            !oldAssets.contains(newAsset)
        }
        let oldCurrencies = self.currencies
        let uniqueCurencies = currencies.filter { newCurrency in
            !oldCurrencies.contains(newCurrency)
        }
        let timeFromLastRequst = Date().timeIntervalSince(lastRequestDate ?? Date.distantPast)
        if uniqueAssets.isNotEmpty || uniqueCurencies.isNotEmpty || timeFromLastRequst > 30 {
            let updatedAssets = oldAssets + uniqueAssets
            let updatedCurrencies = currencies + uniqueCurencies

            pricesProvider = priceLocalSubscriber.subscribeToPrices(
                for: updatedAssets,
                currencies: updatedCurrencies,
                listener: self
            )
            self.chainAssets = updatedAssets
            self.currencies = currencies
            lastRequestDate = Date()
        }
    }

    func handle(prices: [PriceData], for chainAssets: [ChainAsset]) {
        var updatedChains: [ChainModel] = []
        let uniqChains: [ChainModel] = chainAssets.compactMap { $0.chain }.uniq { $0.chainId }
        uniqChains.forEach { chain in
            var updatedAssets: [AssetModel] = []
            chain.chainAssets.forEach { chainAsset in
                let assetPrices = prices.filter { $0.priceId == chainAsset.asset.priceId }
                let updatedAsset = chainAsset.asset.replacingPrice(assetPrices)
                updatedAssets.append(updatedAsset)
            }
            let updatedChain = chain.replacing(updatedAssets)
            updatedChains.append(updatedChain)
        }
        let saveOperation = chainRepository.saveOperation({
            updatedChains
        }, {
            []
        })
        saveOperation.completionBlock = { [weak self] in
            self.listeners.forEach { listener in
                listener.didUpdatePrices(for: chainAssets)
            }
        }
        operationQueue.addOperation(saveOperation)
    }

    func handle(error: Error) {
        logger.error("Prices service failed to get prices: \(error.localizedDescription)")
    }
}
