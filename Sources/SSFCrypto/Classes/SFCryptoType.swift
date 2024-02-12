import Foundation
import SSFModels

public enum SFCryptoType: UInt8, Codable, CaseIterable, Equatable {
    case sr25519
    case ed25519
    case ecdsa
    case ethereumEcdsa
}

public extension SFCryptoType {
    init(utilsType: SSFModels.CryptoType, isEthereum: Bool) {
        switch utilsType {
        case .sr25519:
            self = .sr25519
        case .ed25519:
            self = .ed25519
        case .ecdsa:
            if isEthereum {
                self = .ethereumEcdsa
            } else {
                self = .ecdsa
            }
        }
    }
    init(_ utilsType: SSFModels.CryptoType) {
        switch utilsType {
        case .sr25519:
            self = .sr25519
        case .ed25519:
            self = .ed25519
        case .ecdsa:
            self = .ecdsa
        }
    }

    var utilsType: SSFModels.CryptoType {
        switch self {
        case .sr25519:
            return .sr25519
        case .ed25519:
            return .ed25519
        case .ecdsa, .ethereumEcdsa:
            return .ecdsa
        }
    }
}
