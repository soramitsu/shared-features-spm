import Foundation

public enum Ecosystem: String, Codable, CaseIterable {
    case substrate
    case ethereumBased
    case ethereum
    case ton
    
    public var isSubstrate: Bool {
        switch self {
        case .substrate: return true
        default: return false
        }
    }
    
    public var isEthereumBased: Bool {
        switch self {
        case .ethereumBased: return true
        default: return false
        }
    }
    
    public var isEthereum: Bool {
        switch self {
        case .ethereum: return true
        default: return false
        }
    }
    
    public var isTon: Bool {
        switch self {
        case .ton: return true
        default: return false
        }
    }
}
