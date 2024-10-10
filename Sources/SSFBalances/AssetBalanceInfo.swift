import Foundation
import RobinHood
import SSFModels

public struct AssetBalanceInfo: Codable {
    public enum CodingKeys: String, CodingKey {
        case chainId
        case assetId
        case accountId
        case balanceId
        case balance
        case price
        case deltaPrice
    }

    public let balanceId: String
    public let chainId: String
    public let assetId: String
    public let accountId: String
    public let balance: Decimal?
    public let price: Decimal?
    public let deltaPrice: Decimal?

    public var totalBalance: Decimal? {
        guard let price, let balance else { return nil }
        return price * balance
    }

    public var chainAssetId: String {
        "\(chainId):\(assetId)"
    }

    public init(
        chainId: String,
        assetId: String,
        accountId: String,
        balance: Decimal?,
        price: Decimal?,
        deltaPrice: Decimal?
    ) {
        balanceId = "\(chainId):\(assetId):\(accountId)"
        self.chainId = chainId
        self.assetId = assetId
        self.accountId = accountId
        self.balance = balance
        self.price = price
        self.deltaPrice = deltaPrice
    }
}

extension AssetBalanceInfo: Identifiable {
    public var identifier: String {
        balanceId
    }
}

extension AssetBalanceInfo: Hashable {
    public static func == (lhs: AssetBalanceInfo, rhs: AssetBalanceInfo) -> Bool {
        lhs.balanceId == rhs.balanceId &&
            lhs.balance == rhs.balance &&
            lhs.price == rhs.price &&
            lhs.deltaPrice == rhs.deltaPrice
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(balanceId)
        hasher.combine(balance)
        hasher.combine(price)
        hasher.combine(deltaPrice)
    }
}
