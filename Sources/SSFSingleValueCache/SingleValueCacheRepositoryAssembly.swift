import Foundation
import RobinHood

public typealias SingleValueRepository = AsyncCoreDataRepositoryDefault<SingleValueProviderObject, CDSingleValue>

public protocol SingleValueCacheRepositoryAssembly {
    func createSingleValueCasheRepository() throws -> SingleValueRepository
}

public final class SingleValueCacheRepositoryFactoryDefault: SingleValueCacheRepositoryAssembly {
    public init() {}

    public func createSingleValueCasheRepository() throws -> SingleValueRepository {
        let facade = try CacheStorageFacade()
        let mapper = AnyCoreDataMapper(CodableCoreDataMapper<SingleValueProviderObject, CDSingleValue>())
        let repository = facade.createRepository(
            filter: nil,
            sortDescriptors: [],
            mapper: mapper
        )
        return repository
    }
}
