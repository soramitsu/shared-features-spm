import Foundation

public struct AssetModel: Equatable, Codable, Hashable {
    // swiftlint:disable:next type_name
    public typealias Id = String
    public typealias PriceId = String

    public let id: String
    public let name: String
    public let symbol: String
    public let precision: UInt16
    public let icon: URL?
    public let priceId: PriceId?
    public let price: Decimal?
    public let fiatDayChange: Decimal?
    public let currencyId: String?
    public let existentialDeposit: String?
    public let color: String?
    public let isUtility: Bool
    public let isNative: Bool
    public let staking: RawStakingType?
    public let purchaseProviders: [PurchaseProvider]?
    public let type: ChainAssetType
    public let smartContract: String?

    public var symbolUppercased: String {
        symbol.uppercased()
    }

    public init(
        id: String,
        name: String,
        symbol: String,
        precision: UInt16,
        icon: URL?,
        priceId: AssetModel.PriceId?,
        price: Decimal?,
        fiatDayChange: Decimal?,
        currencyId: String?,
        existentialDeposit: String?,
        color: String?,
        isUtility: Bool,
        isNative: Bool,
        staking: RawStakingType?,
        purchaseProviders: [PurchaseProvider]?,
        type: ChainAssetType,
        smartContract: String?
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.precision = precision
        self.icon = icon
        self.priceId = priceId
        self.price = price
        self.fiatDayChange = fiatDayChange
        self.currencyId = currencyId
        self.existentialDeposit = existentialDeposit
        self.color = color
        self.isUtility = isUtility
        self.isNative = isNative
        self.staking = staking
        self.purchaseProviders = purchaseProviders
        self.type = type
        self.smartContract = smartContract
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        precision = try container.decode(UInt16.self, forKey: .precision)
        icon = try? container.decode(URL?.self, forKey: .icon)
        priceId = try? container.decode(String?.self, forKey: .priceId)
        currencyId = try? container.decode(String?.self, forKey: .currencyId)
        existentialDeposit = try? container.decode(String?.self, forKey: .existentialDeposit)
        color = try? container.decode(String.self, forKey: .color)
        isUtility = (try? container.decode(Bool?.self, forKey: .isUtility)) ?? false
        isNative = (try? container.decode(Bool?.self, forKey: .isNative)) ?? false
        staking = try? container.decode(RawStakingType.self, forKey: .staking)
        purchaseProviders = try? container.decode([PurchaseProvider]?.self, forKey: .purchaseProviders)
        type = try container.decode(ChainAssetType.self, forKey: .type)
        smartContract = try? container.decode(String?.self, forKey: .smartContract)

        price = nil
        fiatDayChange = nil
    }

    public func replacingPrice(_ priceData: PriceData) -> AssetModel {
        AssetModel(
            id: id,
            name: name,
            symbol: symbol,
            precision: precision,
            icon: icon,
            priceId: priceId,
            price: Decimal(string: priceData.price),
            fiatDayChange: priceData.fiatDayChange,
            currencyId: currencyId,
            existentialDeposit: existentialDeposit,
            color: color,
            isUtility: isUtility,
            isNative: isNative,
            staking: staking,
            purchaseProviders: purchaseProviders,
            type: type,
            smartContract: smartContract
        )
    }

    public static func == (lhs: AssetModel, rhs: AssetModel) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.precision == rhs.precision &&
            lhs.icon == rhs.icon &&
            lhs.priceId == rhs.priceId &&
            lhs.symbol == rhs.symbol &&
            lhs.currencyId == rhs.currencyId &&
            lhs.existentialDeposit == rhs.existentialDeposit &&
            lhs.color == rhs.color &&
            lhs.isUtility == rhs.isUtility &&
            lhs.isNative == rhs.isNative &&
            lhs.staking == rhs.staking &&
            lhs.purchaseProviders == rhs.purchaseProviders &&
            lhs.type == rhs.type &&
            lhs.smartContract == rhs.smartContract
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var displayInfo: AssetBalanceDisplayInfo {
        AssetBalanceDisplayInfo(
            displayPrecision: 5,
            assetPrecision: Int16(bitPattern: precision),
            symbol: symbolUppercased,
            symbolValueSeparator: " ",
            symbolPosition: .suffix,
            icon: icon
        )
    }
}

public enum TokenSymbolPosition {
    case prefix
    case suffix
}

public struct AssetBalanceDisplayInfo: Equatable {
    public let displayPrecision: UInt16
    public let assetPrecision: Int16
    public let symbol: String
    public let symbolValueSeparator: String
    public let symbolPosition: TokenSymbolPosition
    public let icon: URL?

    public init(
        displayPrecision: UInt16,
        assetPrecision: Int16,
        symbol: String,
        symbolValueSeparator: String,
        symbolPosition: TokenSymbolPosition,
        icon: URL?
    ) {
        self.displayPrecision = displayPrecision
        self.assetPrecision = assetPrecision
        self.symbol = symbol
        self.symbolValueSeparator = symbolValueSeparator
        self.symbolPosition = symbolPosition
        self.icon = icon
    }
}

