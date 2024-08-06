import Foundation
import IrohaCrypto
import SSFModels
import TonSwift

enum AddressFactory {
    static func accountId(
        from address: AccountAddress,
        chainFormat: ChainFormat
    ) throws -> AccountId {
        try address.toAccountId(using: chainFormat)
    }
}

extension AccountAddress {
    func toAccountId(using conversion: ChainFormat) throws -> AccountId {
        switch conversion {
        case .ethereum:
            return try AccountId(hexStringSSF: self)
        case let .substrate(prefix):
            return try SS58AddressFactory().accountId(fromAddress: self, type: prefix)
        case .ton:
            return try TonSwift.Address.parse(self).asAccountId()
        }
    }
}
