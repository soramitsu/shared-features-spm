import CoreData
import Foundation
import RobinHood
import SSFBalances

extension CDAssetBalance: CoreDataCodable {
    public var entityIdentifierFieldName: String { #keyPath(CDAssetBalance.chainAssetId) }

    public func populate(from decoder: Decoder, using _: NSManagedObjectContext) throws {
        let container = try decoder.container(keyedBy: AssetBalanceInfo.CodingKeys.self)

        assetId = try container.decode(String.self, forKey: .assetId)
        chainId = try container.decode(String.self, forKey: .chainId)
        accountId = try container.decode(String.self, forKey: .accountId)
        chainAssetId = try container.decode(String.self, forKey: .chainAssetId)
        balance = try? container.decodeIfPresent(Decimal.self, forKey: .balance) as NSDecimalNumber?
        price = try? container.decodeIfPresent(Decimal.self, forKey: .price) as NSDecimalNumber?
        deltaPrice = try? container.decodeIfPresent(
            Decimal.self,
            forKey: .deltaPrice
        ) as NSDecimalNumber?
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssetBalanceInfo.CodingKeys.self)

        try container.encode(assetId, forKey: .assetId)
        try container.encode(chainId, forKey: .chainId)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(chainAssetId, forKey: .chainAssetId)
        try container.encodeIfPresent(balance as Decimal?, forKey: .balance)
        try container.encodeIfPresent(price as Decimal?, forKey: .price)
        try container.encodeIfPresent(deltaPrice as Decimal?, forKey: .deltaPrice)
    }
}
