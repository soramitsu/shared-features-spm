import Foundation
import TonSwift
import TonAPI

public struct TonAccount {
    public let address: TonSwift.Address
    public let balance: Int64
    public let status: String
    public let name: String?
    public let icon: String?
    public let isSuspended: Bool?
    public let isWallet: Bool

    public init(account: Components.Schemas.Account) throws {
        address = try TonSwift.Address.parse(account.address)
        balance = account.balance
        status = account.status
        name = account.name
        icon = account.icon
        isSuspended = account.is_suspended
        isWallet = account.is_wallet
    }
}
