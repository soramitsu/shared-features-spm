import Foundation
import RobinHood

typealias IndexersRepository = AsyncCoreDataRepositoryDefault<TransactionHistoryItem, CDTransactionHistoryItem>

protocol IndexersRepositoryAssembly {
    func createRepository() throws -> IndexersRepository
}

final class IndexersRepositoryAssemblyDefault: IndexersRepositoryAssembly {
    func createRepository() throws -> IndexersRepository {
        try IndexersStorageFacade().createRepository()
    }
}
