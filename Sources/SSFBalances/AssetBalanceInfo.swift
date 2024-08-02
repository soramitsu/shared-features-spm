import Foundation
import RobinHood
import SSFModels

public struct AssetBalanceInfo: Codable {
    public enum CodingKeys: String, CodingKey {
        case chainId
        case assetId
        case chainAssetId
        case balance
        case price
        case deltaPrice
    }

    public let chainAssetId: String
    public let chainId: String
    public let assetId: String
    public let balance: Decimal?
    public let price: Decimal?
    public let deltaPrice: Decimal?

    public init(
        chainId: String,
        assetId: String,
        balance: Decimal?,
        price: Decimal?,
        deltaPrice: Decimal?
    ) {
        chainAssetId = "\(chainId):\(assetId)"
        self.chainId = chainId
        self.assetId = assetId
        self.balance = balance
        self.price = price
        self.deltaPrice = deltaPrice
    }
}

extension AssetBalanceInfo: Identifiable {
    public var identifier: String {
        chainAssetId
    }
}

extension AssetBalanceInfo: Hashable {
    public static func == (lhs: AssetBalanceInfo, rhs: AssetBalanceInfo) -> Bool {
        lhs.chainAssetId == rhs.chainAssetId &&
            lhs.balance == rhs.balance &&
            lhs.price == rhs.price &&
            lhs.deltaPrice == rhs.deltaPrice
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(chainAssetId)
        hasher.combine(balance)
        hasher.combine(price)
        hasher.combine(deltaPrice)
    }
}
