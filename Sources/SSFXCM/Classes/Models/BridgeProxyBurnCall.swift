import Foundation
import BigInt
import SSFUtils
import SSFModels

struct BridgeProxyBurnCall: Codable, Equatable {
    let networkId: BridgeTypesGenericNetworkId
    let assetId: SoraAssetId
    let recipient: BridgeTypesGenericAccount
    @StringCodable var amount: BigUInt
}

enum BridgeTypesGenericNetworkId: Codable {
    case evm(BigUInt)
    case sub(BridgeTypesSubNetworkId)
    
    init(from chain: ChainModel) {
        switch chain.chainBaseType {
        case .substrate:
            let networkId = BridgeTypesSubNetworkId(from: chain)
            self = .sub(networkId)
        case .ethereum:
            let evmChainId = BigUInt(stringLiteral: chain.chainId)
            self = .evm(evmChainId)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        switch self {
        case let .evm(id):
            try container.encode("EVM")
            try container.encode(id)
        case let .sub(bridgeTypesSubNetworkId):
            try container.encode("Sub")
            try container.encode(bridgeTypesSubNetworkId)
        }
    }
}

extension BridgeTypesGenericNetworkId: Equatable {
    static func ==(lhs: BridgeTypesGenericNetworkId, rhs: BridgeTypesGenericNetworkId) -> Bool {
        switch (lhs, rhs) {
        case let (.evm(lhsValue), .evm(rhsValue)):
            return lhsValue == rhsValue
        case let (.sub(lhsValue), .sub(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

enum BridgeTypesSubNetworkId: Codable {
    case mainnet
    case kusama
    case polkadot
    case rococo
    case custom(UInt32)

    init(from chain: ChainModel) {
        switch chain.knownChainEquivalent {
        case .soraMain:
            self = .mainnet
        case .kusama:
            self = .kusama
        case .polkadot:
            self = .polkadot
        case .rococo:
            self = .rococo
        default:
            self = .custom(0)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        switch self {
        case .mainnet:
            try container.encode("Mainnet")
            try container.encodeNil()
        case .kusama:
            try container.encode("Kusama")
            try container.encodeNil()
        case .polkadot:
            try container.encode("Polkadot")
            try container.encodeNil()
        case .rococo:
            try container.encode("Rococo")
            try container.encodeNil()
        case let .custom(value):
            try container.encode(value)
        }
    }
}

extension BridgeTypesSubNetworkId: Equatable {
    static func ==(lhs: BridgeTypesSubNetworkId, rhs: BridgeTypesSubNetworkId) -> Bool {
        switch (lhs, rhs) {
        case (.mainnet, .mainnet),
            (.kusama, .kusama),
            (.polkadot, .polkadot),
            (.rococo, .rococo):
            return true
        case let (.custom(lhsValue), .custom(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

enum BridgeTypesGenericAccount: Codable {
    case evm(AccountId)
    case sora(AccountId)
    case parachain(XcmVersionedMultiLocation)
    case unknown
    case root
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        switch self {
        case let .evm(accountId):
            try container.encode("EVM")
            try container.encode(accountId)
        case let .sora(accountId):
            try container.encode("Sora")
            try container.encode(accountId)
        case let .parachain(xcmVersionedMultiLocation):
            try container.encode("Parachain")
            try container.encode(xcmVersionedMultiLocation)
        case .unknown:
            try container.encode("Unknown")
            try container.encodeNil()
        case .root:
            try container.encode("Root")
            try container.encodeNil()
        }
    }
}

extension BridgeTypesGenericAccount: Equatable {
    static func ==(lhs: BridgeTypesGenericAccount, rhs: BridgeTypesGenericAccount) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
            (.root, .root):
            return true
        case let (.evm(lhsValue), .evm(rhsValue)):
            return lhsValue == rhsValue
        case let (.sora(lhsValue), .sora(rhsValue)):
            return lhsValue == rhsValue
        case let (.parachain(lhsValue), .parachain(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

struct SoraAssetId: Codable, Equatable {
    @ArrayCodable var value: String

    init(wrappedValue: String) {
        value = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: Data].self)

        value = dict["code"]?.toHex(includePrefix: true) ?? "-"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard
            let bytes = try? Data(hexStringSSF: value).map({ StringCodable(wrappedValue: $0) })
        else {
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid encoding"
            )
            throw EncodingError.invalidValue(value, context)
        }
        try container.encode(["code": bytes])
    }
}

@propertyWrapper
struct ArrayCodable: Codable, Equatable {
    var wrappedValue: String

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let byteArray = try container.decode([StringScaleMapper<UInt8>].self)
        let value = byteArray.reduce("0x") { $0 + String(format: "%02x", $1.value) }

        wrappedValue = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        guard
            let bytes = try? Data(hexStringSSF: wrappedValue).map({ StringScaleMapper(value: $0) })
        else {
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid encoding"
            )
            throw EncodingError.invalidValue(wrappedValue, context)
        }

        try container.encode(bytes)
    }
}
