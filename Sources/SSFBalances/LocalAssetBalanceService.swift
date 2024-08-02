import Foundation
import RobinHood

public protocol LocalAssetBalanceService {
    func get() async throws -> [AssetBalanceInfo]
    func sync(remoteBalances: [AssetBalanceInfo]) async throws
}

public actor LocalAssetBalanceServiceDefault {
    struct Changes {
        let newOrUpdatedItems: [AssetBalanceInfo]
        let removedItems: [AssetBalanceInfo]
    }

    private let repository: AsyncAnyRepository<AssetBalanceInfo>
    private let operationManager: OperationManagerProtocol

    public init(
        repository: AsyncAnyRepository<AssetBalanceInfo>,
        operationManager: OperationManagerProtocol
    ) {
        self.repository = repository
        self.operationManager = operationManager
    }
}

extension LocalAssetBalanceServiceDefault: LocalAssetBalanceService {
    public func get() async throws -> [AssetBalanceInfo] {
        try await repository.fetchAll(with: RepositoryFetchOptions())
    }

    public func sync(remoteBalances: [AssetBalanceInfo]) async throws {
        let remotePairs = Set(remoteBalances)
        let localPairs = try await Set(repository.fetchAll(with: RepositoryFetchOptions()))

        let newOrUpdatedItems = Array(remotePairs.subtracting(localPairs))
        let removedItems = localPairs.subtracting(remotePairs).map(\.identifier)

        await repository.save(models: newOrUpdatedItems, deleteIds: removedItems)
    }
}
