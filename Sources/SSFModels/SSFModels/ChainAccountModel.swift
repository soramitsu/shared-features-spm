import Foundation

public struct ChainAccountModel: Equatable, Hashable, Codable {
    public let chainId: String
    public let accountId: AccountId
    public let publicKey: Data
    public let cryptoType: UInt8
    public let ecosystem: Ecosystem

    public init(
        chainId: String,
        accountId: AccountId,
        publicKey: Data,
        cryptoType: UInt8,
        ecosystem: Ecosystem
    ) {
        self.chainId = chainId
        self.accountId = accountId
        self.publicKey = publicKey
        self.cryptoType = cryptoType
        self.ecosystem = ecosystem
    }
}
