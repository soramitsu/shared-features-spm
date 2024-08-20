import BigInt
import Foundation
import SSFModels

public protocol XcmMinAmountInspector {
    func inspectMin(
        amount: BigUInt,
        fromChainModel: ChainModel,
        destChainModel: ChainModel,
        assetSymbol: String
    ) throws
}

public final class XcmMinAmountInspectorImpl: XcmMinAmountInspector {
    public init() {}

    public func inspectMin(
        amount: BigUInt,
        fromChainModel: ChainModel,
        destChainModel: ChainModel,
        assetSymbol: String
    ) throws {
        let destination = fromChainModel.xcm?.availableDestinations
            .first(where: { $0.chainId == destChainModel.chainId })
        let minAmount = destination?.assets
            .first(where: { $0.symbol.lowercased() == assetSymbol.lowercased() })?.minAmount

        guard let minAmount,
              let minAmountBigUInt = BigUInt(string: minAmount),
              amount < minAmountBigUInt,
              let precision = fromChainModel.assets
              .first(where: { $0.symbol.lowercased() == assetSymbol.lowercased() })?.precision,
              let minAmountDecimal = Decimal.fromSubstrateAmount(
                  minAmountBigUInt,
                  precision: Int16(precision)
              ) else
        {
            return
        }

        let minAmountWithSymbol = ["\(minAmountDecimal)", assetSymbol.uppercased()]
            .joined(separator: " ")
        throw XcmError.minAmountError(minAmount: minAmountWithSymbol)
    }
}
