import Foundation
import SSFStorageQueryKit
import SSFUtils

public protocol PoolSubscriptionService {
    func createAccountPoolsSubscription(
        accountId: Data,
        baseAssetId: String,
        updateClosure: @escaping (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void
    ) async throws -> UInt16

    func createPoolReservesSubscription(
        baseAssetId: String,
        targetAssetId: String,
        updateClosure: @escaping (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void
    ) async throws -> UInt16

    func unsubscribe(id: UInt16) async throws
}
