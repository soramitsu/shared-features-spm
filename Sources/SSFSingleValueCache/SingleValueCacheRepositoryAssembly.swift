import Foundation
import RobinHood

public typealias AsyncSingleValueRepository = AsyncCoreDataRepositoryDefault<SingleValueProviderObject, CDSingleValue>
public typealias SingleValueRepository = CoreDataRepository<SingleValueProviderObject, CDSingleValue>

public protocol SingleValueCacheRepositoryAssembly {
    func createSingleValueCacheRepository() throws -> SingleValueRepository
    func createAsyncSingleValueCacheRepository() throws -> AsyncSingleValueRepository
}

public final class SingleValueCacheRepositoryFactoryDefault: SingleValueCacheRepositoryAssembly {
    public init() {}

    public func createAsyncSingleValueCacheRepository() throws -> AsyncSingleValueRepository {
        let facade = try CacheStorageFacade()
        let mapper = AnyCoreDataMapper(CodableCoreDataMapper<SingleValueProviderObject, CDSingleValue>())
        let repository = facade.createAsyncRepository(
            filter: nil,
            sortDescriptors: [],
            mapper: mapper
        )
        return repository
    }
    
    public func createSingleValueCacheRepository() throws -> SingleValueRepository {
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
