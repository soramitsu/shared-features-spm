import SSFModels
import RobinHood
import Foundation
import SSFAssetManagment

// sourcery: AutoMockable
public protocol PricesServiceProtocol {
    func getPriceDataFromCache(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [ChainAsset: [PriceData]]
    func getPriceDataFromAPI(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [ChainAsset: [PriceData]]
}

public final class PricesService {
    private let chainRepository: AnyDataProviderRepository<ChainModel>
    private let chainAssetFetcher: ChainAssetFetchingServiceProtocol
    private let operationQueue: OperationQueue
    private let priceProviders: [PriceProviderServiceModel]
    private let chainlinkService: PriceProviderServiceProtocol?
    private let coingeckoService: PriceProviderServiceProtocol?
    private let subqueryService: PriceProviderServiceProtocol?
    private var chainAssets: [ChainAsset] = []
    private var currencies: [Currency] = []
    
    public init(
        chainRepository: AnyDataProviderRepository<ChainModel>,
        chainAssetFetcher: ChainAssetFetchingServiceProtocol,
        operationQueue: OperationQueue,
        priceProviders: [PriceProviderServiceModel],
        chainlinkService: PriceProviderServiceProtocol?,
        coingeckoService: PriceProviderServiceProtocol?,
        subqueryService: PriceProviderServiceProtocol?
    ) {
        self.chainRepository = chainRepository
        self.chainAssetFetcher = chainAssetFetcher
        self.operationQueue = operationQueue
        self.priceProviders = priceProviders
        self.chainlinkService = chainlinkService
        self.coingeckoService = coingeckoService
        self.subqueryService = subqueryService
    }
    
    public func getPriceDataFromCache(
        for chainAssets: [ChainAsset],
        currencies: [Currency]
    ) async -> [ChainAsset: [PriceData]] {
        let allChainAssets = await chainAssetFetcher.fetch(filters: [], sorts: [], forceUpdate: false)
        let requestedChainAssets = allChainAssets.filter { dbChainAsset in
            chainAssets.contains { chainAsset in
                return chainAsset.chain.chainId == dbChainAsset.chain.chainId && chainAsset.asset.id == dbChainAsset.asset.id
            }
        }
        var chainAssetsPriceData: [ChainAsset: [PriceData]] = [:]
        requestedChainAssets.forEach { chainAsset in
            chainAssetsPriceData[chainAsset] = chainAsset.asset.priceData.filter({ priceData in
                currencies.map { $0.id }.contains(priceData.currencyId)
            })
        }
        return chainAssetsPriceData
    }
    
    public func getPriceDataFromAPI(
        for chainAssets: [ChainAsset],
        currencies: [Currency]
    ) async -> [ChainAsset: [PriceData]] {
        async let chainlinkPrices = await self.priceProviders.first { $0.type == .chainlink }?.service
            .getPrices(for: chainAssets, currencies: currencies) ?? []
        async let coingeckoPrices =  await self.priceProviders.first { $0.type == .coingecko }?.service
            .getPrices(for: chainAssets, currencies: currencies) ?? []
        async let subqueryPrices =  await self.priceProviders.first { $0.type == .coingecko }?.service
            .getPrices(for: chainAssets, currencies: currencies) ?? []
        let mergedPrices = await merge(chainlinkPrices: chainlinkPrices, coingeckoPrices: coingeckoPrices, soraSubqueryPrices: subqueryPrices)
        handle(prices: mergedPrices, for: chainAssets)
        var chainAssetsPriceData: [ChainAsset: [PriceData]] = [:]
        chainAssets.forEach { chainAsset in
            chainAssetsPriceData[chainAsset] = mergedPrices.filter { $0.priceId == chainAsset.asset.priceId }
        }
        return chainAssetsPriceData
    }
}

// MARK: - Private methods

private extension PricesService {
    func merge(chainlinkPrices: [PriceData], coingeckoPrices: [PriceData], soraSubqueryPrices: [PriceData]) -> [PriceData] {
        var prices: [PriceData] = []
        prices = self.merge(coingeckoPrices: coingeckoPrices, chainlinkPrices: chainlinkPrices)
        prices = self.merge(coingeckoPrices: prices, soraSubqueryPrices: soraSubqueryPrices)
        return prices
    }

    func merge(coingeckoPrices: [PriceData], chainlinkPrices: [PriceData]) -> [PriceData] {
        if chainlinkPrices.isEmpty {
            let prices = makePrices(from: coingeckoPrices, for: .chainlink)
            return coingeckoPrices + prices
        }
        let caPriceIds = Set(chainAssets.compactMap { $0.asset.coingeckoPriceId })
        let sqPriceIds = Set(chainlinkPrices.compactMap { $0.coingeckoPriceId })

        let replacedFiatDayChange: [PriceData] = chainlinkPrices.compactMap { chainlinkPrice in
            let coingeckoPrice = coingeckoPrices
                .first(where: { $0.coingeckoPriceId == chainlinkPrice.coingeckoPriceId })
            return chainlinkPrice.replaceFiatDayChange(fiatDayChange: coingeckoPrice?.fiatDayChange)
        }

        let filtered = coingeckoPrices.filter { coingeckoPrice in
            guard let coingeckoPriceId = coingeckoPrice.coingeckoPriceId else {
                return true
            }
            return !caPriceIds.intersection(sqPriceIds).contains(coingeckoPriceId)
        }

        return filtered + replacedFiatDayChange
    }

    func merge(
        coingeckoPrices: [PriceData],
        soraSubqueryPrices: [PriceData]
    ) -> [PriceData] {
        if soraSubqueryPrices.isEmpty {
            let prices = makePrices(from: coingeckoPrices, for: .sorasubquery)
            return coingeckoPrices + prices
        }
        let caPriceIds = Set(chainAssets.compactMap { $0.asset.priceId })
        let sqPriceIds = Set(soraSubqueryPrices.compactMap { $0.priceId })

        let filtered = coingeckoPrices.filter { coingeckoPrice in
            let chainAsset = chainAssets
                .first { $0.asset.coingeckoPriceId == coingeckoPrice.priceId }
            guard let priceId = chainAsset?.asset.priceId else {
                return true
            }
            return !caPriceIds.intersection(sqPriceIds).contains(priceId)
        }

        return filtered + soraSubqueryPrices
    }

    func makePrices(
        from coingeckoPrices: [PriceData],
        for type: PriceProviderType
    ) -> [PriceData] {
        let typePriceChainAssets = chainAssets
            .filter { $0.asset.priceProvider?.type == type }

        let prices = coingeckoPrices.filter { coingeckoPrice in
            typePriceChainAssets.contains { chainAsset in
                chainAsset.asset.coingeckoPriceId == coingeckoPrice.coingeckoPriceId
            }
        }

        let newPrices: [PriceData] = prices.compactMap { price in
            guard let chainAsset = typePriceChainAssets
                .first(where: { $0.asset.coingeckoPriceId == price.coingeckoPriceId }) else
            {
                return nil
            }
            return PriceData(
                currencyId: price.currencyId,
                priceId: chainAsset.asset.priceId ?? price.priceId,
                price: price.price,
                fiatDayChange: price.fiatDayChange,
                coingeckoPriceId: price.coingeckoPriceId
            )
        }
        return newPrices
    }
    
    func handle(prices: [PriceData], for chainAssets: [ChainAsset]) {
        var updatedChains: [ChainModel] = []
        let uniqChains: [ChainModel] = chainAssets.compactMap { $0.chain }.uniq { $0.chainId }
        for chain in uniqChains {
            var updatedAssets: [AssetModel] = []
            for chainAsset in chain.chainAssets {
                let assetPrices = prices.filter { $0.priceId == chainAsset.asset.priceId }
                let updatedAsset = chainAsset.asset.replacingPrice(assetPrices)
                updatedAssets.append(updatedAsset)
            }
            let chainRemoteTokens = ChainRemoteTokens(
                type: chain.tokens.type,
                whitelist: chain.tokens.whitelist,
                utilityId: chain.tokens.utilityId,
                tokens: Set(updatedAssets)
            )
            let updatedChain = chain.replacing(chainRemoteTokens)
            updatedChains.append(updatedChain)
        }
        let saveOperation = chainRepository.saveOperation({
            updatedChains
        }, {
            []
        })
        operationQueue.addOperation(saveOperation)
    }
}
