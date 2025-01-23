import Foundation
import IrohaCrypto
import SSFModels
import SSFUtils
import TonSwift

public enum AddressFactory {
    public enum Constants {
        public static let substrateAccountIdLehgth = 32
        public static let ethereumAccountIdLength = 20
    }

    private static let substrateFactory = SS58AddressFactory()
    
    public static func address(
        for accountId: AccountId,
        chain: ChainModel
    ) throws -> AccountAddress {
        try accountId.toAddress(using: chain.chainFormat)
    }

    public static func address(
        for accountId: AccountId,
        chainFormat: ChainFormat
    ) throws -> AccountAddress {
        try accountId.toAddress(using: chainFormat)
    }

    public static func accountId(
        from address: AccountAddress,
        chainFormat: ChainFormat
    ) throws -> AccountId {
        try address.toAccountId(using: chainFormat)
    }

    public static func accountId(
        from address: AccountAddress,
        chain: ChainModel
    ) throws -> AccountId {
        try address.toAccountId(using: chain.chainFormat)
    }

    public static func randomAccountId(for chainFormat: ChainFormat) -> AccountId {
        switch chainFormat {
        case .ethereum:
            return Data(count: EthereumConstants.accountIdLength)
        case .substrate:
            return Data(count: SubstrateConstants.accountIdLength)
        case .ton:
            do {
                return try TonSwift.Address.random().asAccountId()
            } catch {
                return TonSwift.Address.random().hash
            }
        }
    }
}

public extension AccountAddress {
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

    /// Just for substrate and ethereum ecosystem
    /// Don't use for TON
    func toAccountIdWithTryExtractPrefix() throws -> AccountId {
        if hasPrefix("0x") {
            return try AccountId(hexStringSSF: self)
        } else {
            let prefix = try SS58AddressFactory().type(fromAddress: self)
            return try SS58AddressFactory().accountId(fromAddress: self, type: prefix.uint16Value)
        }
    }
}

public extension AccountId {
    func toAddress(using conversion: ChainFormat) throws -> AccountAddress {
        switch conversion {
        case .ethereum:
            return toHex(includePrefix: true)
        case let .substrate(prefix):
            return try SS58AddressFactory().address(fromAccountId: self, type: prefix)
        case let .ton(bounceable):
            return try asTonAddress().toFriendly(bounceable: bounceable).toString()
        }
    }
}

extension ChainAccountModel {
    func toAddress(addressPrefix: UInt16) -> AccountAddress? {
        try? accountId.toAddress(using: .substrate(addressPrefix))
    }
}
