import BigInt
import Foundation
import SSFModels
import SSFUtils

struct BridgeProxyBurnCall: Codable, Equatable {
    let networkId: BridgeTypesGenericNetworkId
    let assetId: SoraAssetId
    let recipient: BridgeTypesGenericAccount
    @StringCodable var amount: BigUInt
}

enum BridgeTypesGenericNetworkId: Codable {
    case evm(BigUInt)
    case sub(BridgeTypesSubNetworkId)

    init(from chain: ChainModel) throws {
        switch chain.ecosystem {
        case .substrate:
            let networkId = try BridgeTypesSubNetworkId(from: chain)
            self = .sub(networkId)
        case .ethereum, .ethereumBased:
            let evmChainId = BigUInt(stringLiteral: chain.chainId)
            self = .evm(evmChainId)
        case .ton:
            throw XcmError.ecosystemNotSupported
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
    static func == (lhs: BridgeTypesGenericNetworkId, rhs: BridgeTypesGenericNetworkId) -> Bool {
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
    case liberland

    init(from chain: ChainModel) throws {
        switch chain.knownChainEquivalent {
        case .soraMain:
            self = .mainnet
        case .rococo:
            self = .rococo
        case .liberland:
            self = .liberland
        default:
            let ecosystem = ChainEcosystem.defineEcosystem(chain: chain)
            switch ecosystem {
            case .kusama:
                self = .kusama
            case .polkadot:
                self = .polkadot
            default:
                throw XcmError.ecosystemNotSupported
            }
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
        case .liberland:
            try container.encode("Liberland")
            try container.encodeNil()
        }
    }
}

extension BridgeTypesSubNetworkId: Equatable {
    static func == (lhs: BridgeTypesSubNetworkId, rhs: BridgeTypesSubNetworkId) -> Bool {
        switch (lhs, rhs) {
        case (.mainnet, .mainnet),
             (.kusama, .kusama),
             (.polkadot, .polkadot),
             (.rococo, .rococo):
            return true
        default:
            return false
        }
    }
}

enum BridgeTypesGenericAccount: Codable {
    case evm(AccountId)
    case sora(AccountId)
    case liberland(AccountId)
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
        case let .liberland(accountId):
            try container.encode("Liberland")
            try container.encode(accountId)
        }
    }
}

extension BridgeTypesGenericAccount: Equatable {
    static func == (lhs: BridgeTypesGenericAccount, rhs: BridgeTypesGenericAccount) -> Bool {
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
        case let (.liberland(lhsValue), .liberland(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
