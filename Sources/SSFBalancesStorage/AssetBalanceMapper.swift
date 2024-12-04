import CoreData
import Foundation
import RobinHood
import SSFBalances

public final class AssetBalanceMapper {
    public var entityIdentifierFieldName: String {
        #keyPath(CDAssetBalance.assetId)
    }

    public typealias DataProviderModel = AssetBalanceInfo
    public typealias CoreDataEntity = CDAssetBalance

    public init() {}
}

extension AssetBalanceMapper: CoreDataMapperProtocol {
    public func transform(entity: CoreDataEntity) throws -> DataProviderModel {
        let assetBalance = AssetBalance(
            balance: entity.assetBalance?.balance as? Decimal,
            lockedBalance: entity.assetBalance?.lockedBalance as? Decimal
        )

        return DataProviderModel(
            chainId: entity.chainId!,
            assetId: entity.assetId!,
            accountId: entity.accountId!,
            price: entity.price as Decimal?,
            deltaPrice: entity.deltaPrice as Decimal?,
            assetBalance: assetBalance
        )
    }

    public func populate(
        entity: CoreDataEntity,
        from model: DataProviderModel,
        using context: NSManagedObjectContext
    ) throws {
        entity.accountId = model.accountId
        entity.chainId = model.chainId
        entity.assetId = model.assetId
        entity.price = model.price as? NSDecimalNumber
        entity.deltaPrice = model.deltaPrice as? NSDecimalNumber
        updateEntityBalance(for: entity, from: model, context: context)
    }
}

private extension AssetBalanceMapper {
    func updateEntityBalance(
        for _: CoreDataEntity,
        from model: DataProviderModel,
        context: NSManagedObjectContext
    ) {
        let balanceEntity = CDBalance(context: context)
        balanceEntity.balance = model.assetBalance?.balance as? NSDecimalNumber
        balanceEntity.lockedBalance = model.assetBalance?.lockedBalance as? NSDecimalNumber
    }
}
