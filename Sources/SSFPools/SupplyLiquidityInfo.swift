import Foundation

public struct SupplyLiquidityInfo {
    public let dexId: String
    public let baseAsset: PooledAssetInfo
    public let targetAsset: PooledAssetInfo
    public let baseAssetAmount: Decimal
    public let targetAssetAmount: Decimal
    public let slippage: Decimal
    
    public var amountMinA: Decimal {
        baseAssetAmount * (Decimal(1) - slippage / 100)
    }
    
    public var amountMinB: Decimal {
        targetAssetAmount * (Decimal(1) - slippage / 100)
    }
}
