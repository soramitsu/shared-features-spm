import RobinHood
import SSFModels

final class SoraSubqueryService: PriceProviderServiceProtocol {
    let soraSubqueryFetcher: SoraSubqueryPriceFetcherProtocol

    init(soraSubqueryFetcher: SoraSubqueryPriceFetcherProtocol) {
        self.soraSubqueryFetcher = soraSubqueryFetcher
    }

    func getPrices(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [PriceData] {
        let operation = createSoraSubqueryOperation(for: chainAssets, currencies: currencies)
        do {
            return try operation.extractNoCancellableResultData()
        } catch {
            return []
        }
    }

    private func createSoraSubqueryOperation(
        for chainAssets: [ChainAsset],
        currencies: [Currency]
    ) -> BaseOperation<[PriceData]> {
        guard currencies.count == 1, currencies.first?.id == Currency.defaultCurrency().id else {
            return BaseOperation.createWithResult([])
        }

        let chainAssets = chainAssets.filter { $0.asset.priceProvider?.type == .sorasubquery }
        guard chainAssets.isNotEmpty else {
            return BaseOperation.createWithResult([])
        }

        let operation = soraSubqueryFetcher.fetchPriceOperation(for: chainAssets)
        return operation
    }
}
