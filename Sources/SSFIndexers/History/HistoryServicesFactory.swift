import RobinHood
import SSFChainRegistry
import SSFNetwork

enum HistoryServiceFactoryType {
    case subquery(txStorage: AsyncAnyRepository<TransactionHistoryItem>, chainRegistry: ChainRegistryProtocol)
    case subsquid(txStorage: AsyncAnyRepository<TransactionHistoryItem>)
    case giansquid(txStorage: AsyncAnyRepository<TransactionHistoryItem>)
    case sora(txStorage: AsyncAnyRepository<TransactionHistoryItem>)
    case etherscan
    case oklink
    case reef(txStorage: AsyncAnyRepository<TransactionHistoryItem>)
    case zeta
}

public enum HistoryServiceFactoryError: Error {
    case unexpectedType
}

protocol HistoryServicesFactoryProtocol {
    func createServices(for types: [HistoryServiceFactoryType])
}

protocol HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService
}

//final class SubqueryHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .subquery(let txStorage, let chainRegistry):
//            let networkWorker = NetworkWorkerDefault()
//            return SubqueryHistoryService(
//                txStorage: txStorage,
//                chainRegistry: chainRegistry,
//                networkWorker: networkWorker
//            )
//        default:
//            return nil
//        }
//    }
//}
//
//final class GiantsquidHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .giantsquid(let txStorage):
//            let networkWorker = NetworkWorkerDefault()
//            return GiantsquidHistoryService(
//                txStorage: txStorage,
//                networkWorker: networkWorker
//            )
//        default:
//            return nil
//        }
//    }
//}
//
//final class SoraHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .sora(let txStorage):
//            let networkWorker = NetworkWorkerDefault()
//            return SoraSubsquidHistoryService(
//                txStorage: txStorage,
//                networkWorker: networkWorker
//            )
//        default:
//            return nil
//        }
//    }
//}
//
//final class EtherscanHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .sora(let txStorage):
//            let networkWorker = NetworkWorkerDefault()
//            return EtherscanHistoryService(networkWorker: networkWorker)
//        default:
//            return nil
//        }
//    }
//}
//
//final class OklinkHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .oklink:
//            let networkWorker = NetworkWorkerDefault()
//            return OklinkHistoryService(networkWorker: networkWorker)
//        default:
//            return nil
//        }
//    }
//}
//
//final class ReefHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .reef(let txStorage):
//            let networkWorker = NetworkWorkerDefault()
//            return ReefSubsquidHistoryService(
//                txStorage: txStorage,
//                networkWorker: networkWorker
//            )
//        default:
//            return nil
//        }
//    }
//}
//
//final class ZetaHistoryServiceFactory: HistoryServiceFactoryProtocol {
//    func createService(factoryType: HistoryServiceFactoryType) -> HistoryService? {
//        switch factoryType {
//        case .zeta:
//            let networkWorker = NetworkWorkerDefault()
//            return ZetaHistoryService(networkWorker: networkWorker)
//        default:
//            return nil
//        }
//    }
//}

final class HistoryServicesFactory: HistoryServiceFactoryProtocol {
    func createService(factoryType: HistoryServiceFactoryType) throws -> HistoryService {
//        problem: We don't know about services if we have factory here or we don't know about factory if it moved to its package
    }
}
