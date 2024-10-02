import Foundation
import TonSwift

public enum WalletEcosystem: Equatable, Codable {
    case regular(Regular)
    case ton(Ton)
    
    // MARK: - Regular

    public struct Regular: Equatable, Codable {
        public let substrateAccountId: Data
        public let substrateCryptoType: UInt8
        public let substratePublicKey: Data
        
        public let ethereumAddress: Data?
        public let ethereumPublicKey: Data?
        
        public init(
            substrateAccountId: Data,
            substrateCryptoType: UInt8,
            substratePublicKey: Data,
            ethereumAddress: Data?,
            ethereumPublicKey: Data?
        ) {
            self.substrateAccountId = substrateAccountId
            self.substrateCryptoType = substrateCryptoType
            self.substratePublicKey = substratePublicKey
            self.ethereumAddress = ethereumAddress
            self.ethereumPublicKey = ethereumPublicKey
        }
    }

    public var substrateAccountId: Data? {
        switch self {
        case .regular(let regular):
            return regular.substrateAccountId
        case .ton:
            return nil
        }
    }

    public var substrateCryptoType: UInt8? {
        switch self {
        case .regular(let regular):
            return regular.substrateCryptoType
        case .ton:
            return nil
        }
    }

    public var substratePublicKey: Data? {
        switch self {
        case .regular(let regular):
            return regular.substratePublicKey
        case .ton:
            return nil
        }
    }

    public var ethereumAddress: Data? {
        switch self {
        case .regular(let regular):
            return regular.ethereumAddress
        case .ton:
            return nil
        }
    }
    
    public var ethereumPublicKey: Data? {
        switch self {
        case .regular(let regular):
            return regular.ethereumPublicKey
        case .ton:
            return nil
        }
    }
    
    // MARK: - Ton
    
    public struct Ton: Equatable, Codable {
        public let tonAddress: TonSwift.Address
        public let tonPublicKey: Data
        public let tonContractVersion: TonContractVersion
        
        public init(
            tonAddress: TonSwift.Address,
            tonPublicKey: Data,
            tonContractVersion: TonContractVersion
        ) {
            self.tonAddress = tonAddress
            self.tonPublicKey = tonPublicKey
            self.tonContractVersion = tonContractVersion
        }
    }

    public var tonAddress: TonSwift.Address? {
        switch self {
        case .regular:
            return nil
        case .ton(let ton):
            return ton.tonAddress
        }
    }

    public var tonPublicKey: Data? {
        switch self {
        case .regular:
            return nil
        case .ton(let ton):
            return ton.tonPublicKey
        }
    }

    public var tonContractVersion: TonContractVersion? {
        switch self {
        case .regular:
            return nil
        case .ton(let ton):
            return ton.tonContractVersion
        }
    }
    
    public func tonWalletContract() -> TonSwift.WalletContract? {
        guard let tonPublicKey = tonPublicKey else {
            return nil
        }

        switch tonContractVersion {
        case .v4R2:
            return WalletV4R2(publicKey: tonPublicKey)
        case .v5R1:
            let walletId = WalletId(networkGlobalId: -239, workchain: 0)
            let wallet = WalletV5R1(publicKey: tonPublicKey, walletId: walletId)
            return wallet
        case .none:
            return nil
        }
    }
}
