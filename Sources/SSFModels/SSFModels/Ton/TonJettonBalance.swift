import Foundation
import BigInt
import TonSwift
import TonAPI

public struct TonJettonBalance: Codable {
    public let item: TonJettonItem
    public let quantity: BigUInt
    
    public init(item: TonJettonItem, quantity: BigUInt) {
        self.item = item
        self.quantity = quantity
    }
}

public struct TonJettonItem: Codable, Equatable {
    public let jettonInfo: TonJettonInfo
    public let walletAddress: TonSwift.Address
    
    public init(jettonInfo: TonJettonInfo, walletAddress: Address) {
        self.jettonInfo = jettonInfo
        self.walletAddress = walletAddress
    }
}

public struct TonJettonInfo: Codable, Equatable, Hashable {
    public enum Verification: Codable {
        case none
        case whitelist
        case blacklist
    }
    
    public let address: TonSwift.Address
    public let fractionDigits: Int
    public let name: String
    public let symbol: String?
    public let verification: Verification
    public let imageURL: URL?

    public init(jettonPreview: Components.Schemas.JettonPreview) throws {
        let tokenAddress = try Address.parse(jettonPreview.address)
        address = tokenAddress
        fractionDigits = jettonPreview.decimals
        name = jettonPreview.name
        symbol = jettonPreview.symbol
        imageURL = URL(string: jettonPreview.image)
        
        let verification: TonJettonInfo.Verification
        switch jettonPreview.verification {
        case .whitelist:
            verification = .whitelist
        case .blacklist:
            verification = .blacklist
        case .none:
            verification = .none
        }
        self.verification = verification
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.address == rhs.address
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
