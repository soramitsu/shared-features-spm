import Foundation
import SSFUtils
import SSFStorageQueryKit

public protocol PoolSubscriptionService {
    func createAccountPoolsSubscription(
        accountId: Data,
        baseAssetId: String,
        updateClosure: @escaping (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void
    ) throws -> UInt16
    
    func createPoolReservesSubscription(
        baseAssetId: String,
        targetAssetId: String,
        updateClosure: @escaping (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void
    ) throws -> UInt16
    
    func unsubscribe(id: UInt16)
    
    func unsubscribeAll()
}
