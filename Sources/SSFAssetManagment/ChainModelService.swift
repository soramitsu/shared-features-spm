import Foundation
import RobinHood
import SSFModels

public protocol ChainModelService {
    func sync(chainModel: [ChainModel]) async throws
}

public final class ChainModelServiceDefault: ChainModelService {
    private let repository: AsyncAnyRepository<ChainModel>

    public init(repository: AsyncAnyRepository<ChainModel>) {
        self.repository = repository
    }

    public func sync(chainModel: [ChainModel]) async throws {
        try await repository.save(models: chainModel)
    }
}
