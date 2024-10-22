import RobinHood
import SSFModels
import SSFUtils

final class CoingeckoService: PriceProviderServiceProtocol {
    let coingeckoOperationFactory: CoingeckoOperationFactoryProtocol

    init(coingeckoOperationFactory: CoingeckoOperationFactoryProtocol) {
        self.coingeckoOperationFactory = coingeckoOperationFactory
    }

    func getPrices(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [PriceData] {
        let operation = createCoingeckoOperation(for: chainAssets, currencies: currencies)
        do {
            return try operation.extractNoCancellableResultData()
        } catch {
            return []
        }
    }

    private func createCoingeckoOperation(
        for chainAssets: [ChainAsset],
        currencies: [Currency]
    ) -> BaseOperation<[PriceData]> {
        let priceIds = chainAssets
            .map { $0.asset.coingeckoPriceId }
            .compactMap { $0 }
            .uniq(predicate: { $0 })
        guard priceIds.isNotEmpty else {
            return BaseOperation.createWithResult([])
        }
        let operation = coingeckoOperationFactory.fetchPriceOperation(
            for: priceIds,
            currencies: currencies
        )
        return operation
    }
}
