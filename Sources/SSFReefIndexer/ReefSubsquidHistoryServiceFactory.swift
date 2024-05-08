import SSFIndex

final class ReefHistoryServiceFactory: HistoryServiceFactoryProtocol {    
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .reef(let txStorage) = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return ReefSubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
}
