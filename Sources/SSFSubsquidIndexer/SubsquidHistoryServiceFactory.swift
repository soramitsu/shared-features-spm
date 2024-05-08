import SSFIndexers

final class SubsquidHistoryServiceFactory: HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .subsquid(let txStorage) = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return SubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
}
