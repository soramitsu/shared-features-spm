import SSFModels

// sourcery: AutoMockable
public protocol PriceProviderServiceProtocol {
    func getPrices(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [PriceData]
}
