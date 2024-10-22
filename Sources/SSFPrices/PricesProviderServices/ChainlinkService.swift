import RobinHood
import SSFChainRegistry
import SSFModels
import SSFUtils

public final class ChainlinkService: PriceProviderServiceProtocol {
    private let chainlinkOperationFactory: ChainlinkOperationFactoryProtocol
    private let chainRegistry: ChainRegistryProtocol

    init(
        chainlinkOperationFactory: ChainlinkOperationFactory,
        chainRegistry: ChainRegistryProtocol
    ) {
        self.chainlinkOperationFactory = chainlinkOperationFactory
        self.chainRegistry = chainRegistry
    }

    func getPrices(for chainAssets: [ChainAsset], currencies: [Currency]) async -> [PriceData] {
        let operations = await createChainlinkOperations(for: chainAssets, currencies: currencies)
        return operations.compactMap {
            try? $0.extractNoCancellableResultData()
        }
    }

    private func createChainlinkOperations(
        for chainAssets: [ChainAsset],
        currencies: [Currency]
    ) async -> [BaseOperation<PriceData>] {
        guard currencies.count == 1, currencies.first?.id == Currency.defaultCurrency().id else {
            return []
        }
        let chainlinkProvider = chainAssets.map { $0.chain }
            .first(where: { $0.options?.contains(.chainlinkProvider) == true })
        guard let provider = chainlinkProvider else {
            return []
        }
        do {
            let connection = try await chainRegistry.getEthereumConnection(for: provider)
            let chainlinkPriceChainAsset = chainAssets
                .filter { $0.asset.priceProvider?.type == .chainlink }

            let operations = chainlinkPriceChainAsset
                .map { chainlinkOperationFactory.priceCall(for: $0, connection: connection) }
            return operations.compactMap { $0 }
        } catch {
            print("can't create ethereum connection for \(provider.name)")
            return []
        }
    }
}
