import Foundation

public enum EthereumAssetType: String, Codable {
    case normal
    case erc20
    case bep20
}

public enum TonAssetType: String, Codable {
    case normal
    case jetton
}

public enum SubstrateAssetType: String, Codable {
    case normal
    case ormlChain
    case ormlAsset
    case foreignAsset
    case stableAssetPoolToken
    case liquidCrowdloan
    case vToken
    case vsToken
    case stable
    case assets
    case equilibrium
    case soraAsset
    case assetId
    case token2
    case xcm
}


public enum ChainAssetType: Codable, Equatable {
    enum AssetBaseType: String, Codable {
        case substrate
        case ethereum
        case ton
    }

    case substrate(substrateType: SubstrateAssetType)
    case ethereum(ethereumType: EthereumAssetType)
    case ton(tonType: TonAssetType)
    
    enum CodingKeys: String, CodingKey {
        case substrate = "type"
        case ethereum = "ethereumType"
        case ton = "tonType"
    }

    public var rawValue: String {
        switch self {
        case let .substrate(substrateType):
            return "substrate-\(substrateType.rawValue)"
        case let .ethereum(ethereumType):
            return "ethereum-\(ethereumType.rawValue)"
        case let .ton(tonType):
            return "ton-\(tonType.rawValue)"
        }
    }

    public init?(storageValue: String?) {
        guard let storageValue else { return nil }
        let components = storageValue.components(separatedBy: "-")
        guard
            let baseTypeValue = components.first,
            let subTypeValue = components.last,
            let baseType = AssetBaseType(rawValue: baseTypeValue)
        else {
            return nil
        }

        switch baseType {
        case .substrate:
            guard let substrateAssetType = SubstrateAssetType(rawValue: subTypeValue) else {
                return nil
            }

            self = .substrate(substrateType: substrateAssetType)
        case .ethereum:
            guard let ethereumAssetType = EthereumAssetType(rawValue: subTypeValue) else {
                return nil
            }

            self = .ethereum(ethereumType: ethereumAssetType)
        case .ton:
            guard let tonType = TonAssetType(rawValue: subTypeValue) else {
                return nil
            }
            self = .ton(tonType: tonType)
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(
                ChainAssetType.self,
                DecodingError.Context.init(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one.",
                    underlyingError: nil
                )
            )
        }
        switch onlyKey {
        case .substrate:
            let type = try container.decode(SubstrateAssetType.self, forKey: .substrate)
            self = .substrate(substrateType: type)
        case .ethereum:
            let type = try container.decode(EthereumAssetType.self, forKey: .ethereum)
            self = .ethereum(ethereumType: type)
        case .ton:
            let type = try container.decode(TonAssetType.self, forKey: .ton)
            self = .ton(tonType: type)
        }
    }

    public var substrateAssetType: SubstrateAssetType? {
        switch self {
        case let .substrate(substrateType):
            return substrateType
        case .ethereum, .ton:
            return nil
        }
    }

    public var ethereumAssetType: EthereumAssetType? {
        switch self {
        case .substrate, .ton:
            return nil
        case let .ethereum(ethereumType):
            return ethereumType
        }
    }
    
    public var tonAssetType: TonAssetType? {
        switch self {
        case let .ton(type):
            return type
        case .ethereum, .substrate:
            return nil
        }
    }
}
