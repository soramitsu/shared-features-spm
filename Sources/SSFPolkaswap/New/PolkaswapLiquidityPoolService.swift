import Foundation
import SSFCrypto
import SSFPools
import sorawallet
import SSFStorageQueryKit
import SSFUtils
import BigInt
import SSFModels

typealias BaseAssetId = String

public enum PolkaswapLiquidityPoolServiceError: Swift.Error {
    case missingReservesAccountId
    case userPoolNotFound(poolId: String)
    case dexIdNotFound(baseAssetId: String)
}

public protocol PolkaswapLiquidityPoolService {
    func subscribeAvailablePools() async throws -> AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error>
    func subscribeUserPools(accountId: AccountId) async throws -> AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error>
    func subscribePoolsReserves(pools: [LiquidityPair]) async throws -> AsyncThrowingStream<CachedStorageResponse<[PolkaswapPoolReservesInfo]>, Swift.Error>
    
    func subscribeLiquidityPool(assetIdPair: AssetIdPair) async throws -> AsyncThrowingStream<CachedStorageResponse<LiquidityPair>, Swift.Error>
    func subscribePoolReserves(assetIdPair: AssetIdPair) async throws -> AsyncThrowingStream<CachedStorageResponse<PolkaswapPoolReservesInfo>, Swift.Error>

    func fetchAvailablePools() async throws -> [LiquidityPair]
    func fetchUserPools(accountId: AccountId) async throws -> [AccountPool]
    func fetchUserPool(assetIdPair: AssetIdPair, accountId: AccountId) async throws -> AccountPool
    func fetchPoolsAPY() async throws -> [PoolApyInfo]
    func fetchReserves(pools: [LiquidityPair]) async throws -> [PolkaswapPoolReservesInfo]
    func fetchDexId(baseAssetId: String) async throws -> String
}

public final class PolkaswapLiquidityPoolServiceDefault {
    private let dexManagerStorage: DexManagerStorage
    private let poolXykStorage: PoolXykStorage
    private let chain: ChainModel
    private let apyWorker: PolkaswapAPYWorker
    
    public init(
        dexManagerStorage: DexManagerStorage,
        poolXykStorage: PoolXykStorage,
        chain: ChainModel,
        apyWorker: PolkaswapAPYWorkerDefault
    ) {
        self.dexManagerStorage = dexManagerStorage
        self.poolXykStorage = poolXykStorage
        self.chain = chain
        self.apyWorker = apyWorker
    }
}

extension PolkaswapLiquidityPoolServiceDefault: PolkaswapLiquidityPoolService {
    public func fetchDexId(baseAssetId: String) async throws -> String {
        let dexInfos = try await dexManagerStorage.dexInfos(chain: chain)
        
        let dexInfosArray = dexInfos.compactMap { [$0.value.baseAssetId.code: $0.key] }
        let dexIdByBaseAssetId = Dictionary(dexInfosArray.flatMap { $0 }, uniquingKeysWith: { _, last in last })
        guard let dexId = dexIdByBaseAssetId[baseAssetId] else {
            throw PolkaswapLiquidityPoolServiceError.dexIdNotFound(baseAssetId: baseAssetId)
        }
        
        return dexId
    }
    
    public func fetchUserPool(assetIdPair: AssetIdPair, accountId: AccountId) async throws -> AccountPool {
        let pool = try await fetchUserPools(accountId: accountId).first(where: { $0.poolId == assetIdPair.poolId })
        
        guard let pool else {
            throw PolkaswapLiquidityPoolServiceError.userPoolNotFound(poolId: assetIdPair.poolId)
        }
        
        return pool
    }
    
    public func fetchUserPools(accountId: AccountId) async throws -> [AccountPool] {
        async let totalIssuanceByReservesIdPromise = try await poolXykStorage.totalIssuance(chain: chain)
        
        let userPools = try await poolXykStorage.accountPools(accountId: accountId, chain: chain)
        let pairs: [AssetIdPair] = userPools.compactMap { $0.assetPair }
        
        async let propertiesByPairPromise = try await poolXykStorage.properties(pairs: pairs, chain: chain)
        async let poolReservesInfosPromise = try await poolXykStorage.reserves(pairs: pairs, chain: chain)
        
        let properties = try await propertiesByPairPromise
        let providers = try await poolXykStorage.poolProviders(properties: properties.compactMap { $0.value }, accountId: accountId, chain: chain)
        
        let totalIssuanceByReservesId = try await totalIssuanceByReservesIdPromise
        let poolReservesInfos = try await poolReservesInfosPromise
        
        let pools: [AccountPool] = await pairs.asyncCompactMap { assetPair in
            let baseAssetId = assetPair.baseAssetId.code
            let targetAssetId = assetPair.targetAssetId.code
            let id = "\(baseAssetId)-\(targetAssetId)"
            let reservesIdKey = AssetIdPair(baseAssetIdCode: baseAssetId, targetAssetIdCode: targetAssetId)
            let poolProperties = properties[reservesIdKey]
            
            guard
                let baseAsset = chain.assets.first(where: { $0.currencyId == baseAssetId }),
                let targetAsset = chain.assets.first(where: { $0.currencyId == targetAssetId }),
                let reservesId = poolProperties?.reservesId
            else {
                return nil
            }
            let totalIssuance = totalIssuanceByReservesId[reservesId]
            let reserves = poolReservesInfos.first(where: { $0.poolId == id })?.reserves
            let poolProviderKey = PoolProvidersStorageKey(reservesId: reservesId, accountId: accountId)
            let accountPoolBalance = providers[poolProviderKey]
            let totalIssuancesDecimal = Decimal.fromSubstrateAmount(
                totalIssuance.or(.zero),
                precision: Int16(baseAsset.precision)
            ) ?? Decimal(0)

            let reservesDecimal = Decimal.fromSubstrateAmount(
                reserves?.reserves ?? BigUInt.zero,
                precision: Int16(baseAsset.precision)
            ) ?? Decimal(0)

            let accountPoolBalanceDecimal = Decimal.fromSubstrateAmount(
                accountPoolBalance.or(.zero),
                precision: Int16(baseAsset.precision)
            ) ?? Decimal(0)

            let targetAssetPooledTotal = Decimal.fromSubstrateAmount(
                reserves?.fee ?? BigUInt.zero,
                precision: Int16(targetAsset.precision)
            ) ?? Decimal(0)

            let areThereIssuances = totalIssuancesDecimal > 0

            let accountPoolShare = areThereIssuances ? accountPoolBalanceDecimal /
                totalIssuancesDecimal * 100 : .zero
            let baseAssetPooled = areThereIssuances ? reservesDecimal * accountPoolBalanceDecimal /
                totalIssuancesDecimal : .zero
            let targetAssetPooled = areThereIssuances ? targetAssetPooledTotal *
                accountPoolBalanceDecimal / totalIssuancesDecimal : .zero
            let reservationIdString = reservesId.toHex()

            return AccountPool(
                poolId: id,
                accountId: accountId.toHex(),
                chainId: chain.chainId,
                baseAssetId: baseAssetId,
                targetAssetId: targetAssetId,
                baseAssetPooled: baseAssetPooled,
                targetAssetPooled: targetAssetPooled,
                accountPoolShare: accountPoolShare,
                reservesId: reservationIdString
            )
        }
        
        return pools
    }
    
    public func fetchAvailablePools() async throws -> [LiquidityPair] {
        let dexInfos = try await dexManagerStorage.dexInfos(chain: chain)
        let pairs = try await poolXykStorage.properties(baseAssetIds: dexInfos.compactMap { $0.value.baseAssetId }, chain: chain)

        return try pairs.compactMap {
            let reservesAccountId = $0.value.reservesId
            let baseAssetId = $0.key.baseAssetId.code
            let targetAssetId = $0.key.targetAssetId.code
            let reservesId = try AddressFactory.address(
                for: reservesAccountId,
                chainFormat: self.chain.chainFormat
            )
            
            return LiquidityPair(
                pairId: "\(baseAssetId)-\(targetAssetId)",
                chainId: nil,
                baseAssetId: baseAssetId,
                targetAssetId: targetAssetId,
                reservesId: reservesId
            )
        }
    }

    public func fetchPoolsAPY() async throws -> [PoolApyInfo] {
        let apyInfo = try await apyWorker.getAPYInfo()
        return apyInfo.compactMap {
            PoolApyInfo(poolId: $0.id, apy: $0.sbApy?.decimalValue)
        }
    }
    
    public func fetchReserves(pools: [LiquidityPair]) async throws -> [PolkaswapPoolReservesInfo] {
        return try await poolXykStorage.reserves(pairs: pools.compactMap { AssetIdPair(baseAssetIdCode: $0.baseAssetId, targetAssetIdCode: $0.targetAssetId) }, chain: chain)
    }
    
    public func subscribeUserPools(accountId: AccountId) async throws -> AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error> {
        AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error> { continuation in
            Task {
                let userPoolsStream = await self.poolXykStorage.subscribeAccountPools(accountId: accountId, chain: self.chain)
                for try await userPool in userPoolsStream {
                    guard let userPool = userPool.value else {
                        continuation.finish(throwing: PoolXykStorageError.accountPoolsNotFound(accountId: accountId))
                        return
                    }
                    
                    let pools: [UserPool] = userPool.compactMap { userPool in
                        return userPool.value.compactMap {
                            let assetIdPair = AssetIdPair(baseAssetIdCode: userPool.key.second.value, targetAssetIdCode: $0.value)
                            
                            return UserPool(
                                accountId: accountId,
                                assetPair: assetIdPair
                            )
                        }
                    }.reduce([UserPool](), +)
                    
                    let propertiesStream = try await poolXykStorage.subscribeProperties(pairs: pools.compactMap { $0.assetPair }, chain: chain)
                    
                    for try await properties in propertiesStream {
                        let pairs = properties.value?.compactMap {
                            let reservesAccountId = $0.value.reservesId
                            let baseAssetId = $0.key.baseAssetId.code
                            let targetAssetId = $0.key.targetAssetId.code
                            let reservesId = reservesAccountId.toHex()
                            
                            return LiquidityPair(
                                pairId: "\(baseAssetId)-\(targetAssetId)",
                                chainId: nil,
                                baseAssetId: baseAssetId,
                                targetAssetId: targetAssetId,
                                reservesId: reservesId
                            )
                        }
                                   
                        let response = CachedStorageResponse(value: pairs, type: properties.type)
                        continuation.yield(response)
                    }
                }
                
            }
        }
    }
    
    
    public func subscribeAvailablePools() async throws -> AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error> {
        AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error> { continuation in
            Task {
                let dexInfosStream = try await dexManagerStorage.subscribeDexInfos(chain: chain)
                
                for try await dexInfo in dexInfosStream {
                    guard let dexInfo = dexInfo.value else {
                        continuation.yield(CachedStorageResponse<[LiquidityPair]>.empty)
                        return
                    }
                    
                    let poolPropertiesStream = await poolXykStorage.subscribeProperties(baseAssetIds: dexInfo.compactMap { $0.value.baseAssetId }, chain: chain)
                    for try await properties in poolPropertiesStream {
                        let pairs = properties.value?.compactMap {
                            let reservesAccountId = $0.value.reservesId
                            let baseAssetId = $0.key.baseAssetId.code
                            let targetAssetId = $0.key.targetAssetId.code
                            let reservesId = reservesAccountId.toHex()
                            return LiquidityPair(
                                pairId: "\(baseAssetId)-\(targetAssetId)",
                                chainId: nil,
                                baseAssetId: baseAssetId,
                                targetAssetId: targetAssetId,
                                reservesId: reservesId
                            )
                        }
                        
                        let response = CachedStorageResponse(value: pairs, type: properties.type)
                                                
                        continuation.yield(response)
                    }
                }
            }
        }
    }
    
    public func subscribePoolsReserves(pools: [LiquidityPair]) async throws -> AsyncThrowingStream<CachedStorageResponse<[PolkaswapPoolReservesInfo]>, Swift.Error> {
        AsyncThrowingStream<CachedStorageResponse<[PolkaswapPoolReservesInfo]>, Swift.Error> { continuation in
            Task {
                let assetPairs = pools.compactMap {
                    AssetIdPair(baseAssetIdCode: $0.baseAssetId, targetAssetIdCode: $0.targetAssetId)
                }
                let stream = try await self.poolXykStorage.subscribePoolsReserves(pairs: assetPairs, chain: self.chain)
                
                for try await reserves in stream {
                    let reservesInfo = reserves.value?.compactMap { PolkaswapPoolReservesInfo(poolId: $0.key.poolId, reserves: $0.value) }
                    let response = CachedStorageResponse(value: reservesInfo, type: reserves.type)
                    
                    continuation.yield(response)
                }
            }
        }
    }
    
    public func subscribeLiquidityPool(assetIdPair: AssetIdPair) async throws -> AsyncThrowingStream<CachedStorageResponse<LiquidityPair>, Swift.Error> {
        AsyncThrowingStream<CachedStorageResponse<LiquidityPair>, Swift.Error> { continuation in
            Task {
                let poolPropertiesStream = try await poolXykStorage.subscribePoolProperties(pair: assetIdPair, chain: chain)
                for try await properties in poolPropertiesStream {
                    let reservesAccountId = properties.value?.reservesId
                    let reservesId = reservesAccountId?.toHex()
                    let liquidityPair = LiquidityPair(
                        pairId: "\(assetIdPair.baseAssetId.code)-\(assetIdPair.targetAssetId.code)",
                        chainId: nil,
                        baseAssetId: assetIdPair.baseAssetId.code,
                        targetAssetId: assetIdPair.targetAssetId.code,
                        reservesId: reservesId
                    )
                    
                    let response = CachedStorageResponse(value: liquidityPair, type: properties.type)
                    
                    continuation.yield(response)
                }
            }
        }
    }
    
    public func subscribePoolReserves(assetIdPair: AssetIdPair) async throws -> AsyncThrowingStream<CachedStorageResponse<PolkaswapPoolReservesInfo>, Swift.Error> {
        AsyncThrowingStream<CachedStorageResponse<PolkaswapPoolReservesInfo>, Swift.Error> { continuation in
            Task {
                let stream = try await self.poolXykStorage.subscribePoolReserves(pair: assetIdPair, chain: self.chain)
                
                for try await reserves in stream {
                    guard let reservesValue = reserves.value else {
                        continuation.yield(with: .failure(PoolXykStorageError.reservesNotFound(pairs: [assetIdPair])))
                        return
                    }
                    let reservesInfo = PolkaswapPoolReservesInfo(poolId: assetIdPair.poolId, reserves: reservesValue)
                    let response = CachedStorageResponse(value: reservesInfo, type: reserves.type)
                    
                    continuation.yield(response)
                }
            }
        }
    }
}
