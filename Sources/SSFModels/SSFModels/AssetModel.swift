import Foundation

public struct TokenProperties: Codable, Hashable {
    public let priceId: String?
    public let currencyId: String?
    public let color: String?
    public let type: SubstrateAssetType?
    public let isNative: Bool?
    public let staking: RawStakingType?

    public init(
        priceId: String? = nil,
        currencyId: String? = nil,
        color: String? = nil,
        type: SubstrateAssetType? = nil,
        isNative: Bool = false,
        staking: RawStakingType? = nil
    ) {
        self.priceId = priceId
        self.currencyId = currencyId
        self.color = color
        self.type = type
        self.isNative = isNative
        self.staking = staking
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        priceId = try? container.decode(String.self, forKey: .priceId)
        currencyId = nil
        color = try? container.decode(String.self, forKey: .color)
        type = try? container.decode(SubstrateAssetType.self, forKey: .type)
        isNative = try? container.decode(Bool.self, forKey: .isNative)
        staking = try? container.decode(RawStakingType.self, forKey: .staking)
    }

    public func encode(to _: Encoder) throws {}
}

extension TokenProperties {
    private enum CodingKeys: String, CodingKey {
        case priceId
        case currencyId
        case color
        case type
        case isNative
        case staking
    }
}

public struct AssetModel: Equatable, Codable, Hashable, Identifiable {
    public typealias Id = String
    public typealias PriceId = String

    public var identifier: String { id }

    public let id: String
    public let name: String
    public let symbol: String
    public let precision: UInt16
    public let icon: URL?
    public let existentialDeposit: String?
    public let isUtility: Bool
    public let purchaseProviders: [PurchaseProvider]?
    public let ethereumType: EthereumAssetType?
    public let tokenProperties: TokenProperties?
    public let priceProvider: PriceProvider?

    public let coingeckoPriceId: PriceId?
    public var priceId: PriceId? {
        if let priceProvider = priceProvider {
            return priceProvider.id
        }

        return coingeckoPriceId
    }

    public var symbolUppercased: String {
        symbol.uppercased()
    }

    public var priceData: [PriceData]

    public init(
        id: String,
        name: String,
        symbol: String,
        precision: UInt16,
        icon: URL? = nil,
        tokenProperties: TokenProperties?,
        existentialDeposit: String? = nil,
        isUtility: Bool,
        purchaseProviders: [PurchaseProvider]? = nil,
        ethereumType: EthereumAssetType? = nil,
        priceProvider: PriceProvider? = nil,
        coingeckoPriceId: PriceId? = nil,
        priceData: [PriceData] = []
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.precision = precision
        self.icon = icon
        self.existentialDeposit = existentialDeposit
        self.isUtility = isUtility
        self.purchaseProviders = purchaseProviders
        self.ethereumType = ethereumType
        self.tokenProperties = tokenProperties
        self.priceProvider = priceProvider
        self.coingeckoPriceId = coingeckoPriceId
        self.priceData = priceData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        precision = try container.decode(UInt16.self, forKey: .precision)
        icon = try? container.decode(URL?.self, forKey: .icon)
        existentialDeposit = try? container.decode(String?.self, forKey: .existentialDeposit)
        isUtility = (try? container.decode(Bool?.self, forKey: .isUtility)) ?? false
        purchaseProviders = try? container.decode(
            [PurchaseProvider]?.self,
            forKey: .purchaseProviders
        )
        ethereumType = try? container.decode(EthereumAssetType?.self, forKey: .ethereumType)
        tokenProperties = try? container.decode(TokenProperties?.self, forKey: .tokenProperties)

        coingeckoPriceId = try? container.decode(String?.self, forKey: .priceId)
        priceProvider = try container.decodeIfPresent(PriceProvider.self, forKey: .priceProvider)

        priceData = []
    }

    public func encode(to _: Encoder) throws {}

    public func replacingPrice(_ priceData: [PriceData]) -> AssetModel {
        AssetModel(
            id: id,
            name: name,
            symbol: symbol,
            precision: precision,
            icon: icon,
            tokenProperties: tokenProperties, existentialDeposit: existentialDeposit,
            isUtility: isUtility,
            purchaseProviders: purchaseProviders,
            ethereumType: ethereumType,
            priceProvider: priceProvider,
            coingeckoPriceId: coingeckoPriceId,
            priceData: priceData
        )
    }

    public func getPrice(for currency: Currency) -> PriceData? {
        priceData.first { $0.currencyId == currency.id }
    }

    public static func == (lhs: AssetModel, rhs: AssetModel) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.precision == rhs.precision &&
            lhs.icon == rhs.icon &&
            lhs.symbol == rhs.symbol &&
            lhs.tokenProperties == rhs.tokenProperties &&
            lhs.existentialDeposit == rhs.existentialDeposit &&
            lhs.isUtility == rhs.isUtility &&
            lhs.purchaseProviders == rhs.purchaseProviders &&
            lhs.ethereumType == rhs.ethereumType &&
            lhs.priceProvider == rhs.priceProvider
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AssetModel {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case icon
        case tokenProperties
        case priceId
        case existentialDeposit
        case isUtility
        case purchaseProviders
        case ethereumType
        case priceProvider
        case precision
    }
}
