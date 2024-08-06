import Foundation
import SSFModels
import BigInt
import TonSwift

public enum Token: Equatable {
    case ton
    case jetton(jettonWalletAddress: Address)
}

public struct TonTransfer {
    public let amount: BigUInt
    public let token: Token
    public let isMax: Bool
    public let contract: WalletContract
    public let sender: Address
    public let recipientAddress: RecipientAddress
    public let comment: String?
    
    public init(
        amount: BigUInt,
        token: Token,
        isMax: Bool,
        contract: WalletContract,
        sender: Address,
        recipientAddress: RecipientAddress,
        comment: String?
    ) {
        self.amount = amount
        self.token = token
        self.isMax = isMax
        self.sender = sender
        self.recipientAddress = recipientAddress
        self.comment = comment
        self.contract = contract
    }
}

public enum RecipientAddress: Equatable {
    case friendly(FriendlyAddress)
    case raw(Address)
    
    public var address: Address {
        switch self {
        case .friendly(let friendlyAddress):
            return friendlyAddress.address
        case .raw(let address):
            return address
        }
    }
    
    public var isBouncable: Bool {
        switch self {
        case .friendly(let friendlyAddress):
            return friendlyAddress.isBounceable
        case .raw:
            return false
        }
    }
}
//public struct Recipient: Equatable {
//    
//    public let recipientAddress: RecipientAddress
//    public let isMemoRequired: Bool
//}
