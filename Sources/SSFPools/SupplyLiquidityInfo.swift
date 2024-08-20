import Foundation

public struct SupplyLiquidityInfo {
    public let dexId: String
    public let baseAsset: PooledAssetInfo
    public let targetAsset: PooledAssetInfo
    public let baseAssetAmount: Decimal
    public let targetAssetAmount: Decimal
    public let slippage: Decimal
    public let availablePairs: [LiquidityPair]?

    public var amountMinA: Decimal {
        baseAssetAmount * (Decimal(1) - slippage / 100)
    }

    public var amountMinB: Decimal {
        targetAssetAmount * (Decimal(1) - slippage / 100)
    }

    public init(
        dexId: String,
        baseAsset: PooledAssetInfo,
        targetAsset: PooledAssetInfo,
        baseAssetAmount: Decimal,
        targetAssetAmount: Decimal,
        slippage: Decimal,
        availablePairs: [LiquidityPair]?
    ) {
        self.dexId = dexId
        self.baseAsset = baseAsset
        self.targetAsset = targetAsset
        self.baseAssetAmount = baseAssetAmount
        self.targetAssetAmount = targetAssetAmount
        self.slippage = slippage
        self.availablePairs = availablePairs
    }
}
