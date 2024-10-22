import SSFModels

protocol PriceProviderServiceProtocol {
    func getPrices(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [PriceData]
}
