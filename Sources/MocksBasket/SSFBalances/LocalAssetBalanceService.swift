import Foundation
import SSFPools
import RobinHood

public protocol LocalAccountPoolsService {
    func get() async throws -> [AccountPool]
    func sync(remoteAccounts: [AccountPool]) async throws
}

public final class LocalAccountPairServiceDefault {
    struct Changes {
        let newOrUpdatedItems: [AccountPool]
        let removedItems: [AccountPool]
    }

    private let repository: AnyDataProviderRepository<AccountPool>
    private let operationManager: OperationManagerProtocol

    public init(
        repository: AnyDataProviderRepository<AccountPool>,
        operationManager: OperationManagerProtocol
    ) {
        self.repository = repository
        self.operationManager = operationManager
    }
}

extension LocalAccountPairServiceDefault: LocalAccountPoolsService {
    public func get() async throws -> [AccountPool] {
        let fetchOperation = repository.fetchAllOperation(with: RepositoryFetchOptions())
        operationManager.enqueue(operations: [fetchOperation], in: .transient)

        return try await withCheckedThrowingContinuation { continuation in
            fetchOperation.completionBlock = {
                do {
                    let localPairs = try fetchOperation.extractNoCancellableResultData()
                    continuation.resume(returning: localPairs)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func sync(remoteAccounts: [AccountPool]) async throws {
        let fetchOperation = repository.fetchAllOperation(with: RepositoryFetchOptions())

        let processingOperation: BaseOperation<Changes> = ClosureOperation {
            let remotePairs = Set(remoteAccounts)
            let localPairs = try Set(fetchOperation.extractNoCancellableResultData())
            let newOrUpdatedItems = remotePairs.subtracting(localPairs)
            let removedItems = localPairs.subtracting(remotePairs)
            return Changes(
                newOrUpdatedItems: Array(newOrUpdatedItems),
                removedItems: Array(removedItems)
            )
        }

        let localSaveOperation = repository.saveOperation({
            let changes = try processingOperation.extractNoCancellableResultData()
            return changes.newOrUpdatedItems
        }, {
            let changes = try processingOperation.extractNoCancellableResultData()
            return changes.removedItems.map(\.poolId)
        })

        processingOperation.addDependency(fetchOperation)
        localSaveOperation.addDependency(processingOperation)

        operationManager.enqueue(
            operations: [fetchOperation, processingOperation, localSaveOperation],
            in: .transient
        )

        return try await withCheckedThrowingContinuation { continuation in
            localSaveOperation.completionBlock = {
                do {
                    try localSaveOperation.extractNoCancellableResultData()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
