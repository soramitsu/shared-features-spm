import Foundation
import RobinHood

public typealias AsyncSingleValueRepository = AsyncCoreDataRepositoryDefault<
    SingleValueProviderObject,
    CDSingleValue
>
public typealias SingleValueRepository = CoreDataRepository<
    SingleValueProviderObject,
    CDSingleValue
>

public protocol SingleValueCacheRepositoryAssembly {
    func createSingleValueCacheRepository() -> SingleValueRepository
    func createAsyncSingleValueCacheRepository() -> AsyncSingleValueRepository
}

public final class SingleValueCacheRepositoryFactoryDefault: SingleValueCacheRepositoryAssembly {
    public init() {}

<<<<<<< HEAD
    public func createAsyncSingleValueCacheRepository() -> AsyncSingleValueRepository {
        let facade = CacheStorageFacade()
        let mapper = AnyCoreDataMapper(CodableCoreDataMapper<SingleValueProviderObject, CDSingleValue>())
=======
    public func createAsyncSingleValueCacheRepository() throws -> AsyncSingleValueRepository {
        let facade = try CacheStorageFacade()
        let mapper = AnyCoreDataMapper(CodableCoreDataMapper<
            SingleValueProviderObject,
            CDSingleValue
        >())
>>>>>>> 25a9ff2 (Update tests)
        let repository = facade.createAsyncRepository(
            filter: nil,
            sortDescriptors: [],
            mapper: mapper
        )
        return repository
    }
<<<<<<< HEAD
    
    public func createSingleValueCacheRepository() -> SingleValueRepository {
=======

    public func createSingleValueCacheRepository() throws -> SingleValueRepository {
>>>>>>> 25a9ff2 (Update tests)
        let facade = try CacheStorageFacade()
        let mapper = AnyCoreDataMapper(CodableCoreDataMapper<
            SingleValueProviderObject,
            CDSingleValue
        >())
        let repository = facade.createRepository(
            filter: nil,
            sortDescriptors: [],
            mapper: mapper
        )
        return repository
    }
}
