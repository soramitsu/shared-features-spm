import SSFIndexers

final class ZetaHistoryServiceFactory: HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
        guard case .zeta = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return ZetaHistoryService(networkWorker: networkWorker)
    }
}
