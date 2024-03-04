import Foundation
import IrohaCrypto
import SSFModels

public enum AddressFactory {
    private static let substrateFactory = SS58AddressFactory()

    public static func address(
        for accountId: AccountId,
        chainFormat: SFChainFormat
    ) throws -> AccountAddress {
        try accountId.toAddress(using: chainFormat)
    }

    public static func accountId(
        from address: AccountAddress,
        chainFormat: SFChainFormat
    ) throws -> AccountId {
        try address.toAccountId(using: chainFormat)
    }

    public static func randomAccountId(for chainFormat: SFChainFormat) -> AccountId {
        switch chainFormat {
        case .sfEthereum:
            return Data(count: EthereumConstants.accountIdLength)
        case .sfSubstrate:
            return Data(count: SubstrateConstants.accountIdLength)
        }
    }
    
    public static func accountId(from address: AccountAddress, chain: ChainModel) throws -> AccountId {
        try address.toAccountId(using: chainFormat(of: chain))
    }
    
    private static func chainFormat(of chain: ChainModel) -> SFChainFormat {
        chain.isEthereumBased ? .sfEthereum : .sfSubstrate(chain.addressPrefix)
    }
}

public extension AccountId {
    func toAddress(using conversion: SFChainFormat) throws -> AccountAddress {
        switch conversion {
        case .sfEthereum:
            return toHex(includePrefix: true)
        case let .sfSubstrate(prefix):
            return try SS58AddressFactory().address(fromAccountId: self, type: prefix)
        }
    }
}

public extension AccountAddress {
    func toAccountId(using conversion: SFChainFormat) throws -> AccountId {
        switch conversion {
        case .sfEthereum:
            return try AccountId(hexStringSSF: self)
        case let .sfSubstrate(prefix):
            return try SS58AddressFactory().accountId(fromAddress: self, type: prefix)
        }
    }
}
