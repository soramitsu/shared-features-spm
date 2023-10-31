import Foundation

public enum ChainEcosystem: String, Equatable {
    private enum Constants {
        static let polkadotGenesisHash = "91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3"
        static let kusamaGenesisHash = "b0a8d493285c2df73290dfb7e61f870f17b41801197a149ca93654499ea3dafe"
    }
    
    case kusama
    case polkadot
    case westend
    case ethereum
    case unknown

    var isKusama: Bool {
        return self == .kusama
    }

    var isPolkadot: Bool {
        return self == .polkadot
    }
    
    public static func defineEcosystem(chain: ChainModel) -> ChainEcosystem {
        if chain.parentId == Constants.polkadotGenesisHash || chain.isPolkadot {
            return .polkadot
        }
        
        if chain.parentId == Constants.kusamaGenesisHash || chain.isKusama {
            return .kusama
        }
        
        if chain.isWestend {
            return .westend
        }
        
        return .unknown
    }
    
}
