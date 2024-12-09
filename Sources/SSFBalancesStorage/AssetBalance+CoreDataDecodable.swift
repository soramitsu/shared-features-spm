import CoreData
import Foundation
import RobinHood
import SSFBalances

extension CDAssetBalance: CoreDataCodable {
    public var entityIdentifierFieldName: String { #keyPath(CDAssetBalance.balanceId) }

    public func populate(from decoder: Decoder, using context: NSManagedObjectContext) throws {
        let container = try decoder.container(keyedBy: AssetBalanceInfo.CodingKeys.self)

        assetId = try container.decode(String.self, forKey: .assetId)
        chainId = try container.decode(String.self, forKey: .chainId)
        accountId = try container.decode(String.self, forKey: .accountId)
        balanceId = try container.decode(String.self, forKey: .balanceId)
        price = try? container.decodeIfPresent(Decimal.self, forKey: .price) as NSDecimalNumber?
        deltaPrice = try? container.decodeIfPresent(
            Decimal.self,
            forKey: .deltaPrice
        ) as NSDecimalNumber?

        do {
            let decodedAssetBalance = try container.decode(AssetBalance.self, forKey: .assetBalance)

            let cdBalance = CDBalance(context: context)
            cdBalance.assetBalanceId = decodedAssetBalance.assetBalanceId
            cdBalance.balance = decodedAssetBalance.balance as NSDecimalNumber?
            cdBalance.lockedBalance = decodedAssetBalance.lockedBalance as NSDecimalNumber?
            assetBalance = cdBalance
        } catch {
            print(
                "Failed to decode AssetBalance or create CDBalance: \(error.localizedDescription)"
            )
            assetBalance = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AssetBalanceInfo.CodingKeys.self)

        try container.encode(assetId, forKey: .assetId)
        try container.encode(chainId, forKey: .chainId)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(balanceId, forKey: .balanceId)
        try container.encodeIfPresent(price as Decimal?, forKey: .price)
        try container.encodeIfPresent(deltaPrice as Decimal?, forKey: .deltaPrice)

        if let assetBalance = assetBalance, let balanceId = assetBalance.assetBalanceId {
            let encodedAssetBalance = AssetBalance(
                assetBalanceId: balanceId,
                balance: assetBalance.balance as Decimal?,
                lockedBalance: assetBalance.lockedBalance as Decimal?
            )
            try container.encode(encodedAssetBalance, forKey: .assetBalance)
        }
    }
}

extension CDBalance: CoreDataCodable {
    public var entityIdentifierFieldName: String { #keyPath(CDBalance.assetBalanceId) }

    public func populate(from decoder: any Decoder, using _: NSManagedObjectContext) throws {
        let container = try decoder.container(keyedBy: AssetBalance.CodingKeys.self)
        balance = try? container.decodeIfPresent(Decimal.self, forKey: .balance) as
            NSDecimalNumber?

        lockedBalance = try? container.decodeIfPresent(
            Decimal.self,
            forKey: .lockedBalance
        ) as NSDecimalNumber?
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AssetBalance.CodingKeys.self)
        try container.encodeIfPresent(balance as Decimal?, forKey: .balance)
        try container.encodeIfPresent(lockedBalance as Decimal?, forKey: .lockedBalance)
    }
}
