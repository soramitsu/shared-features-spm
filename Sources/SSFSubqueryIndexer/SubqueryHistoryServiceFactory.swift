import SSFIndexers

final class SubqueryHistoryServiceFactory: HistoryServiceFactoryProtocol {    
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
        guard case .subquery(let txStorage, let chainRegistry) = factoryType else {
            throw HistoryServiceFactoryError.unexpectedType
        }
        let networkWorker = NetworkWorkerDefault()
        return SubqueryHistoryService(
            txStorage: txStorage,
            chainRegistry: chainRegistry,
            networkWorker: networkWorker
        )
    }
}
