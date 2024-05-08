import SSFIndexers

final class SoraHistoryServiceFactory: HistoryServiceFactoryProtocol {    
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .sora(let txStorage) = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return SoraSubsquidHistoryService(
            txStorage: txStorage,
            networkWorker: networkWorker
        )
    }
}
