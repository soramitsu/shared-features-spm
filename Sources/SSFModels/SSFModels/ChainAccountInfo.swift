import Foundation

// depricated
public enum CryptoType: UInt8, Codable, CaseIterable {
    case sr25519
    case ed25519
    case ecdsa

    public var stringValue: String {
        switch self {
        case .sr25519:
            return "sr25519"
        case .ed25519:
            return "ed25519"
        case .ecdsa:
            return "ecdsa"
        }
    }

    public var supportsSeedFromSecretKey: Bool {
        switch self {
        case .ed25519, .ecdsa:
            return true
        case .sr25519:
            return false
        }
    }

    public
    init?(rawValue: String) {
        switch rawValue {
        case "sr25519":
            self = .sr25519
        case "ed25519":
            self = .ed25519
        case "ecdsa":
            self = .ecdsa
        default:
            return nil
        }
    }
}

public struct ChainAccountResponse: Equatable {
    public let chainId: ChainModel.Id
    public let accountId: AccountId
    public let publicKey: Data
    public let name: String
    public let cryptoType: CryptoType
    public let addressPrefix: UInt16
    public let isEthereumBased: Bool
    public let isChainAccount: Bool
    public let walletId: String

    public init(
        chainId: ChainModel.Id,
        accountId: AccountId,
        publicKey: Data,
        name: String,
        cryptoType: CryptoType,
        addressPrefix: UInt16,
        isEthereumBased: Bool,
        isChainAccount: Bool,
        walletId: String
    ) {
        self.chainId = chainId
        self.accountId = accountId
        self.publicKey = publicKey
        self.name = name
        self.cryptoType = cryptoType
        self.addressPrefix = addressPrefix
        self.isEthereumBased = isEthereumBased
        self.isChainAccount = isChainAccount
        self.walletId = walletId
    }
}

public struct ChainAccountInfo {
    public let chain: ChainModel
    public let account: ChainAccountResponse

    public init(chain: ChainModel, account: ChainAccountResponse) {
        self.chain = chain
        self.account = account
    }
}
