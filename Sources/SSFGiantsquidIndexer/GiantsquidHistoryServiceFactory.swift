import SSFIndexers

final class GiantsquidHistoryServiceFactory: HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .giantsquid(let txStorage) = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return GiantsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
}
