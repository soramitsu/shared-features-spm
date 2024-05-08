import SSFIndexers

final class OklinkHistoryServiceFactory: HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .oklink = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return OklinkHistoryService(networkWorker: networkWorker)
    }
}
