import Foundation
import RobinHood
import SSFUtils
import SSFModels

public typealias RuntimeVersionUpdate = JSONRPCSubscriptionUpdate<RuntimeVersion>
public typealias StorageSubscriptionUpdate = JSONRPCSubscriptionUpdate<StorageUpdate>
public typealias JSONRPCQueryOperation = JSONRPCOperation<StorageQuery, [StorageUpdate]>
public typealias SuperIdentityOperation = BaseOperation<[StorageResponse<SuperIdentity>]>
public typealias SuperIdentityWrapper = CompoundOperationWrapper<[StorageResponse<SuperIdentity>]>
public typealias IdentityOperation = BaseOperation<[StorageResponse<Identity>]>
public typealias IdentityWrapper = CompoundOperationWrapper<[StorageResponse<Identity>]>
public typealias SlashingSpansWrapper = CompoundOperationWrapper<[StorageResponse<SlashingSpans>]>
public typealias UnappliedSlashesOperation = BaseOperation<[StorageResponse<[UnappliedSlash]>]>
public typealias UnappliedSlashesWrapper = CompoundOperationWrapper<[StorageResponse<[UnappliedSlash]>]>
