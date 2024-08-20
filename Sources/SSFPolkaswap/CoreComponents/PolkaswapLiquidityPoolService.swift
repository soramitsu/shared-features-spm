import BigInt
import Foundation
import sorawallet
import SSFCrypto
import SSFModels
import SSFNetwork
import SSFPools
import SSFStorageQueryKit
import SSFUtils

typealias BaseAssetId = String

public enum PolkaswapLiquidityPoolServiceError: Swift.Error {
    case missingReservesAccountId
    case userPoolNotFound(poolId: String)
    case dexIdNotFound(baseAssetId: String)
    case totalIssuanceNotFound(reservesId: AccountId)
}

public protocol PolkaswapLiquidityPoolService {
    func subscribeAvailablePools() async throws
        -> AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error>
    func subscribeUserPools(accountId: AccountId) async throws
        -> AsyncThrowingStream<CachedStorageResponse<[AccountPool]>, Swift.Error>
    func subscribePoolsReserves(pools: [LiquidityPair]) async throws
        -> AsyncThrowingStream<CachedStorageResponse<[PolkaswapPoolReservesInfo]>, Swift.Error>

    func subscribeLiquidityPool(assetIdPair: AssetIdPair) async throws
        -> AsyncThrowingStream<CachedStorageResponse<LiquidityPair>, Swift.Error>
    func subscribePoolReserves(assetIdPair: AssetIdPair) async throws
        -> AsyncThrowingStream<CachedStorageResponse<PolkaswapPoolReservesInfo>, Swift.Error>
    func subscribePoolsAPY(poolIds: [String]) async throws
        -> AsyncThrowingStream<[CachedNetworkResponse<PoolApyInfo>], Swift.Error>

    func fetchAvailablePools() async throws -> [LiquidityPair]
    func fetchUserPools(accountId: AccountId) async throws -> [AccountPool]
    func fetchUserPool(assetIdPair: AssetIdPair, accountId: AccountId) async throws -> AccountPool
    func fetchPoolsAPY(poolIds: [String]) async throws -> [PoolApyInfo]
    func fetchReserves(pools: [LiquidityPair]) async throws -> [PolkaswapPoolReservesInfo]
    func fetchDexId(baseAssetId: String) async throws -> String
    func fetchTotalIssuance(reservesId: AccountId) async throws -> BigUInt
}

public final class PolkaswapLiquidityPoolServiceDefault {
    private let dexManagerStorage: DexManagerStorage
    private let poolXykStorage: PoolXykStorage
    private let chain: ChainModel
    private let apyFetcher: PoolsApyFetcher

    public init(
        dexManagerStorage: DexManagerStorage,
        poolXykStorage: PoolXykStorage,
        chain: ChainModel,
        apyFetcher: PoolsApyFetcher
    ) {
        self.dexManagerStorage = dexManagerStorage
        self.poolXykStorage = poolXykStorage
        self.chain = chain
        self.apyFetcher = apyFetcher
    }
}

extension PolkaswapLiquidityPoolServiceDefault: PolkaswapLiquidityPoolService {
    public func fetchDexId(baseAssetId: String) async throws -> String {
        let dexInfos = try await dexManagerStorage.dexInfos(chain: chain)

        let dexInfosArray = dexInfos.compactMap { [$0.value.baseAssetId.code: $0.key] }
        let dexIdByBaseAssetId = Dictionary(
            dexInfosArray.flatMap { $0 },
            uniquingKeysWith: { _, last in last }
        )
        guard let dexId = dexIdByBaseAssetId[baseAssetId] else {
            throw PolkaswapLiquidityPoolServiceError.dexIdNotFound(baseAssetId: baseAssetId)
        }

        return dexId
    }

    public func fetchUserPool(
        assetIdPair: AssetIdPair,
        accountId: AccountId
    ) async throws -> AccountPool {
        let pool = try await fetchUserPools(accountId: accountId)
            .first(where: { $0.poolId == assetIdPair.poolId })

        guard let pool else {
            throw PolkaswapLiquidityPoolServiceError.userPoolNotFound(poolId: assetIdPair.poolId)
        }

        return pool
    }

    public func fetchUserPools(accountId: AccountId) async throws -> [AccountPool] {
        async let totalIssuanceByReservesIdPromise = try await poolXykStorage
            .totalIssuance(chain: chain)

        let dexInfos = try await dexManagerStorage.dexInfos(chain: chain)
        let userPools = try await poolXykStorage.accountPools(accountId: accountId, chain: chain)
        let pairs: [AssetIdPair] = userPools.compactMap { $0.assetPair }

        async let propertiesByPairPromise = try await poolXykStorage.properties(
            pairs: pairs,
            chain: chain
        )
        async let poolReservesInfosPromise = try await poolXykStorage.reserves(
            pairs: pairs,
            chain: chain
        )

        let properties = try await propertiesByPairPromise
        let providers = try await poolXykStorage.poolProviders(
            properties: properties.compactMap { $0.value },
            accountId: accountId,
            chain: chain
        )

        let totalIssuanceByReservesId = try await totalIssuanceByReservesIdPromise
        let poolReservesInfos = try await poolReservesInfosPromise

        let pools: [AccountPool] = await pairs.asyncCompactMap { assetPair in
            let baseAssetId = assetPair.baseAssetId.code
            let targetAssetId = assetPair.targetAssetId.code
            let id = "\(baseAssetId)-\(targetAssetId)"
            let reservesIdKey = AssetIdPair(
                baseAssetIdCode: baseAssetId,
                targetAssetIdCode: targetAssetId
            )
            let poolProperties = properties[reservesIdKey]

            guard let baseAsset = chain.assets.first(where: { $0.currencyId == baseAssetId }),
                  let targetAsset = chain.assets.first(where: { $0.currencyId == targetAssetId }),
                  let reservesId = poolProperties?.reservesId,
                  let dexId = dexInfos
                  .first(where: { $0.value.baseAssetId.code == assetPair.baseAssetId.code })?.key else {
                return nil
            }
            let totalIssuance = totalIssuanceByReservesId[reservesId]
            let reserves = poolReservesInfos.first(where: { $0.poolId == id })?.reserves
            let poolProviderKey = PoolProvidersStorageKey(
                reservesId: reservesId,
                accountId: accountId
            )
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
                dexId: "",
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
        let pairs = try await poolXykStorage.properties(
            baseAssetIds: dexInfos.compactMap { $0.value.baseAssetId },
            chain: chain
        )

        let dexIdByBaseAssetIdArray = dexInfos.compactMap { [$0.value.baseAssetId.code: $0.key] }
        let tupleArray: [(String, String)] = dexIdByBaseAssetIdArray.flatMap { $0 }
        let dexIdByBaseAssetId = Dictionary(tupleArray, uniquingKeysWith: { _, last in last })

        return try pairs.compactMap {
            let reservesAccountId = $0.value.reservesId
            let baseAssetId = $0.key.baseAssetId.code
            let targetAssetId = $0.key.targetAssetId.code
            let reservesId = try AddressFactory.address(
                for: reservesAccountId,
                chainFormat: self.chain.chainFormat
            )

            guard let dexId = dexIdByBaseAssetId[baseAssetId] else {
                return nil
            }

            return LiquidityPair(
                dexId: dexId,
                pairId: "\(baseAssetId)-\(targetAssetId)",
                chainId: nil,
                baseAssetId: baseAssetId,
                targetAssetId: targetAssetId,
                reservesId: reservesId
            )
        }
    }

    public func fetchPoolsAPY(poolIds: [String]) async throws -> [PoolApyInfo] {
        try await apyFetcher.fetch(poolIds: poolIds)
    }

    public func fetchReserves(pools: [LiquidityPair]) async throws -> [PolkaswapPoolReservesInfo] {
        let pairs = pools.compactMap { AssetIdPair(
            baseAssetIdCode: $0.baseAssetId,
            targetAssetIdCode: $0.targetAssetId
        ) }
        return try await poolXykStorage.reserves(pairs: pairs, chain: chain)
    }

    public func fetchTotalIssuance(reservesId: AccountId) async throws -> BigUInt {
        let totalIssuanceByReservesId = try await poolXykStorage.totalIssuance(chain: chain)

        guard let totalIssuance = totalIssuanceByReservesId[reservesId] else {
            throw PolkaswapLiquidityPoolServiceError.totalIssuanceNotFound(reservesId: reservesId)
        }

        return totalIssuance
    }

    public func subscribePoolsAPY(poolIds: [String]) async throws
        -> AsyncThrowingStream<[CachedNetworkResponse<PoolApyInfo>], Swift.Error>
    {
        try await apyFetcher.subscribe(poolIds: poolIds)
    }

    public func subscribeUserPools(accountId: AccountId) async throws
        -> AsyncThrowingStream<CachedStorageResponse<[AccountPool]>, Swift.Error>
    {
        AsyncThrowingStream<
            CachedStorageResponse<[AccountPool]>,
            Swift.Error
        > { continuation in
            Task {
                let dexInfosStream = await self.dexManagerStorage
                    .subscribeDexInfos(chain: self.chain)
                let totalIssuanceStream = await self.poolXykStorage
                    .subscribeTotalIssuance(chain: self.chain)
                let userPoolsStream = await self.poolXykStorage.subscribeAccountPools(
                    accountId: accountId,
                    chain: self.chain
                )

                var fetchedDexInfos: DexInfoByDexId?
                var fetchedTotalIssuance: [Data: StringScaleMapper<BigUInt>]?
                var fetchedReserves: [AssetIdPair: PolkaswapPoolReserves]?
                var fetchedUserPools: [ScaleTuple<Data, SoraAssetId>: [SoraAssetId]]?
                var fetchedProperties: [AssetIdPair: LiquidityPoolProperties]?
                var fetchedProviders: [PoolProvidersStorageKey: StringScaleMapper<BigUInt>]?

                for try await(dexInfos) in dexInfosStream {
                    if dexInfos.value != nil && fetchedDexInfos != nil,
                       dexInfos.value?.isEmpty == false,
                       fetchedDexInfos?.isEmpty == false,
                       fetchedDexInfos == dexInfos.value
                    {
                        continue
                    }

                    fetchedDexInfos = dexInfos.value
                    await self.deriveUserPools(
                        continuation: continuation,
                        dexInfos: fetchedDexInfos,
                        totalIssuance: fetchedTotalIssuance,
                        reserves: fetchedReserves,
                        properties: fetchedProperties,
                        providers: fetchedProviders,
                        accountId: accountId
                    )

                    for try await totalIssuance in totalIssuanceStream {
                        if totalIssuance.value != nil && fetchedTotalIssuance != nil,
                           totalIssuance.value?.isEmpty == false,
                           fetchedTotalIssuance?.isEmpty == false,
                           fetchedTotalIssuance == totalIssuance.value
                        {
                            continue
                        }

                        fetchedTotalIssuance = totalIssuance.value
                        await self.deriveUserPools(
                            continuation: continuation,
                            dexInfos: fetchedDexInfos,
                            totalIssuance: fetchedTotalIssuance,
                            reserves: fetchedReserves,
                            properties: fetchedProperties,
                            providers: fetchedProviders,
                            accountId: accountId
                        )

                        for try await userPool in userPoolsStream {
                            if userPool.value != nil && fetchedUserPools != nil,
                               userPool.value?.isEmpty == false,
                               fetchedUserPools?.isEmpty == false,
                               fetchedUserPools == userPool.value
                            {
                                continue
                            }

                            fetchedUserPools = userPool.value
                            await self.deriveUserPools(
                                continuation: continuation,
                                dexInfos: fetchedDexInfos,
                                totalIssuance: fetchedTotalIssuance,
                                reserves: fetchedReserves,
                                properties: fetchedProperties,
                                providers: fetchedProviders,
                                accountId: accountId
                            )

                            guard let fetchedUserPools else {
                                continue
                            }

                            let assetIdPairs = fetchedUserPools.compactMap { userPool in
                                userPool.value.compactMap {
                                    AssetIdPair(
                                        baseAssetIdCode: userPool.key.second.value,
                                        targetAssetIdCode: $0.value
                                    )
                                }
                            }.reduce([], +)

                            guard !assetIdPairs.isEmpty else {
                                continue
                            }

                            let propertiesStream = try await self.poolXykStorage
                                .subscribeProperties(
                                    pairs: assetIdPairs,
                                    chain: self.chain
                                )
                            let reservesStream = try await self.poolXykStorage
                                .subscribePoolsReserves(
                                    pairs: assetIdPairs,
                                    chain: self.chain
                                )

                            for try await reserves in reservesStream {
                                if reserves.value != nil && fetchedReserves != nil,
                                   reserves.value?.isEmpty == false,
                                   fetchedReserves?.isEmpty == false,
                                   fetchedReserves == reserves.value
                                {
                                    continue
                                }

                                fetchedReserves = reserves.value
                                await self.deriveUserPools(
                                    continuation: continuation,
                                    dexInfos: fetchedDexInfos,
                                    totalIssuance: fetchedTotalIssuance,
                                    reserves: fetchedReserves,
                                    properties: fetchedProperties,
                                    providers: fetchedProviders,
                                    accountId: accountId
                                )
                                for try await properties in propertiesStream {
                                    if properties.value != nil && fetchedProperties != nil,
                                       properties.value?.isEmpty == false,
                                       fetchedProperties?.isEmpty == false,
                                       fetchedProperties == properties.value
                                    {
                                        continue
                                    }

                                    fetchedProperties = properties.value
                                    await self.deriveUserPools(
                                        continuation: continuation,
                                        dexInfos: fetchedDexInfos,
                                        totalIssuance: fetchedTotalIssuance,
                                        reserves: fetchedReserves,
                                        properties: fetchedProperties,
                                        providers: fetchedProviders,
                                        accountId: accountId
                                    )

                                    guard let fetchedProperties else {
                                        continue
                                    }

                                    let propertiesParameters = fetchedProperties
                                        .compactMap { $0.value }
                                    guard !propertiesParameters.isEmpty else {
                                        continue
                                    }

                                    let providersStream = try await self.poolXykStorage
                                        .subscribePoolProviders(
                                            properties: propertiesParameters,
                                            accountId: accountId,
                                            chain: self.chain
                                        )

                                    for try await providers in providersStream {
                                        if providers.value != nil && fetchedProviders != nil,
                                           providers.value?.isEmpty == false,
                                           fetchedProviders?.isEmpty == false,
                                           fetchedProviders == providers.value
                                        {
                                            continue
                                        }

                                        fetchedProviders = providers.value
                                        await self.deriveUserPools(
                                            continuation: continuation,
                                            dexInfos: fetchedDexInfos,
                                            totalIssuance: fetchedTotalIssuance,
                                            reserves: fetchedReserves,
                                            properties: fetchedProperties,
                                            providers: fetchedProviders,
                                            accountId: accountId
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public func subscribeAvailablePools() async throws
        -> AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error>
    {
        AsyncThrowingStream<CachedStorageResponse<[LiquidityPair]>, Swift.Error> { continuation in
            Task {
                let dexInfosStream = await dexManagerStorage.subscribeDexInfos(chain: chain)

                for try await dexInfo in dexInfosStream {
                    guard let dexInfo = dexInfo.value else {
                        continuation.yield(CachedStorageResponse<[LiquidityPair]>.empty)
                        return
                    }

                    let dexIdByBaseAssetIdArray = dexInfo
                        .compactMap { [$0.value.baseAssetId.code: $0.key] }
                    let tupleArray: [(String, String)] = dexIdByBaseAssetIdArray.flatMap { $0 }
                    let dexIdByBaseAssetId = Dictionary(
                        tupleArray,
                        uniquingKeysWith: { _, last in last }
                    )

                    let poolPropertiesStream = await poolXykStorage.subscribeProperties(
                        baseAssetIds: dexInfo.compactMap { $0.value.baseAssetId },
                        chain: chain
                    )
                    for try await properties in poolPropertiesStream {
                        let pairs: [LiquidityPair]? = properties.value?.compactMap {
                            let reservesAccountId = $0.value.reservesId
                            let baseAssetId = $0.key.baseAssetId.code
                            let targetAssetId = $0.key.targetAssetId.code
                            let reservesId = reservesAccountId.toHex()

                            guard let dexId = dexIdByBaseAssetId[baseAssetId] else {
                                return nil
                            }

                            return LiquidityPair(
                                dexId: dexId,
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

    public func subscribePoolsReserves(pools: [LiquidityPair]) async throws
        -> AsyncThrowingStream<CachedStorageResponse<[PolkaswapPoolReservesInfo]>, Swift.Error>
    {
        AsyncThrowingStream<
            CachedStorageResponse<[PolkaswapPoolReservesInfo]>,
            Swift.Error
        > { continuation in
            Task {
                let assetPairs = pools.compactMap {
                    AssetIdPair(
                        baseAssetIdCode: $0.baseAssetId,
                        targetAssetIdCode: $0.targetAssetId
                    )
                }
                let stream = try await self.poolXykStorage.subscribePoolsReserves(
                    pairs: assetPairs,
                    chain: self.chain
                )

                for try await reserves in stream {
                    let reservesInfo = reserves.value?.compactMap { PolkaswapPoolReservesInfo(
                        poolId: $0.key.poolId,
                        reserves: $0.value
                    ) }
                    let response = CachedStorageResponse(value: reservesInfo, type: reserves.type)

                    continuation.yield(response)
                }
            }
        }
    }

    public func subscribeLiquidityPool(assetIdPair: AssetIdPair) async throws
        -> AsyncThrowingStream<CachedStorageResponse<LiquidityPair>, Swift.Error>
    {
        AsyncThrowingStream<CachedStorageResponse<LiquidityPair>, Swift.Error> { continuation in
            Task {
                let dexInfos = try await dexManagerStorage.dexInfos(chain: chain)
                let poolPropertiesStream = try await poolXykStorage.subscribePoolProperties(
                    pair: assetIdPair,
                    chain: chain
                )
                let dexIdByBaseAssetIdArray = dexInfos
                    .compactMap { [$0.value.baseAssetId.code: $0.key] }
                let tupleArray: [(String, String)] = dexIdByBaseAssetIdArray.flatMap { $0 }
                let dexIdByBaseAssetId = Dictionary(
                    tupleArray,
                    uniquingKeysWith: { _, last in last }
                )

                for try await properties in poolPropertiesStream {
                    let reservesAccountId = properties.value?.reservesId
                    let reservesId = reservesAccountId?.toHex()

                    guard let dexId = dexIdByBaseAssetId[assetIdPair.baseAssetId.code] else {
                        return
                    }

                    let liquidityPair = LiquidityPair(
                        dexId: dexId,
                        pairId: "\(assetIdPair.baseAssetId.code)-\(assetIdPair.targetAssetId.code)",
                        chainId: nil,
                        baseAssetId: assetIdPair.baseAssetId.code,
                        targetAssetId: assetIdPair.targetAssetId.code,
                        reservesId: reservesId
                    )

                    let response = CachedStorageResponse(
                        value: liquidityPair,
                        type: properties.type
                    )

                    continuation.yield(response)
                }
            }
        }
    }

    public func subscribePoolReserves(assetIdPair: AssetIdPair) async throws
        -> AsyncThrowingStream<CachedStorageResponse<PolkaswapPoolReservesInfo>, Swift.Error>
    {
        AsyncThrowingStream<
            CachedStorageResponse<PolkaswapPoolReservesInfo>,
            Swift.Error
        > { continuation in
            Task {
                let stream = try await self.poolXykStorage.subscribePoolReserves(
                    pair: assetIdPair,
                    chain: self.chain
                )

                for try await reserves in stream {
                    guard let reservesValue = reserves.value else {
                        continuation
                            .yield(with: .failure(
                                PoolXykStorageError
                                    .reservesNotFound(pairs: [assetIdPair])
                            ))
                        return
                    }
                    let reservesInfo = PolkaswapPoolReservesInfo(
                        poolId: assetIdPair.poolId,
                        reserves: reservesValue
                    )
                    let response = CachedStorageResponse(value: reservesInfo, type: reserves.type)

                    continuation.yield(response)
                }
            }
        }
    }

    // MARK: Private

    private func deriveUserPools(
        continuation: AsyncThrowingStream<CachedStorageResponse<[AccountPool]>, Swift.Error>
            .Continuation,
        dexInfos: DexInfoByDexId?,
        totalIssuance: [Data: StringScaleMapper<BigUInt>]?,
        reserves: [AssetIdPair: PolkaswapPoolReserves]?,
        properties: [AssetIdPair: LiquidityPoolProperties]?,
        providers: [PoolProvidersStorageKey: StringScaleMapper<BigUInt>]?,
        accountId: AccountId
    ) async {
        guard let totalIssuance, let reserves, let properties, let providers, let dexInfos else {
            return
        }
        let pairs: [AssetIdPair] = properties.compactMap { $0.key }
        let accountPools: [AccountPool] = await pairs.asyncCompactMap { assetPair in
            let baseAssetId = assetPair.baseAssetId.code
            let targetAssetId = assetPair.targetAssetId.code
            let id = "\(baseAssetId)-\(targetAssetId)"
            let reservesIdKey = AssetIdPair(
                baseAssetIdCode: baseAssetId,
                targetAssetIdCode: targetAssetId
            )
            let poolProperties = properties[reservesIdKey]

            guard let baseAsset = chain.assets.first(where: { $0.currencyId == baseAssetId }),
                  let targetAsset = chain.assets.first(where: { $0.currencyId == targetAssetId }),
                  let reservesId = poolProperties?.reservesId,
                  let dexId = dexInfos
                  .first(where: { $0.value.baseAssetId.code == assetPair.baseAssetId.code })?.key else {
                return nil
            }

            let totalIssuance = totalIssuance[reservesId]?.value
            let reserves = reserves[reservesIdKey]

            let poolProviderKey = PoolProvidersStorageKey(
                reservesId: reservesId,
                accountId: accountId
            )
            let accountPoolBalance = providers[poolProviderKey]?.value
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
                dexId: dexId,
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

        let response = CachedStorageResponse(value: accountPools, type: .cache)
        continuation.yield(response)
    }
}
