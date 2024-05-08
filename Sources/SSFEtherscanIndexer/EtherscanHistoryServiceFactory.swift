import SSFIndexers

final class EtherscanHistoryServiceFactory: HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .sora(let txStorage) = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return EtherscanHistoryService(networkWorker: networkWorker)
    }
}
