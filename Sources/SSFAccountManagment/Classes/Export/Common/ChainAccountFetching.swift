import Foundation
import SSFModels
import TonSwift

public enum ChainAccountFetchingError: Error {
   case accountNotExists
}

public extension ChainAccountResponse {
   func toDisplayAddress(bounceable: Bool = true) throws -> DisplayAddress {
       switch ecosystem {
       case .substrate:
           let address = try accountId.toAddress(using: .substrate(addressPrefix))
           return DisplayAddress(address: address, username: name)
       case .ethereum, .ethereumBased:
           let address = try accountId.toAddress(using: .ethereum)
           return DisplayAddress(address: address, username: name)
       case .ton:
           let address = try accountId.asTonAddress().toFriendly(bounceable: bounceable).toString()
           return DisplayAddress(address: address, username: name)
       }
   }

   func toAddress(bounceable: Bool = true) -> AccountAddress? {
       switch ecosystem {
       case .substrate:
           return try? accountId.toAddress(using: .substrate(addressPrefix))
       case .ethereum, .ethereumBased:
           return try? accountId.toAddress(using: .ethereum)
       case .ton:
           return try? accountId.asTonAddress().toFriendly(bounceable: bounceable).toString()
       }
   }

   func chainFormat(bounceable: Bool = true) -> ChainFormat {
       switch ecosystem {
       case .substrate:
           return .substrate(addressPrefix)
       case .ethereum, .ethereumBased:
           return .ethereum
       case .ton:
           return .ton(bounceable: bounceable)
       }
   }
}

public extension MetaAccountModel {
   func fetch(for request: ChainAccountRequest) -> ChainAccountResponse? {
       if let chainAccount = chainAccounts.first(where: { $0.chainId == request.chainId }) {
           return chainAccountResponse(for: chainAccount, request: request)
       }

       switch request.ecosystem {
       case .substrate:
           return substrateResponse(for: request)
       case .ethereum, .ethereumBased:
           return ethereumResponse(for: request)
       case .ton:
           return tonResponse(for: request)
       }
   }
    
    func fetchChainAccountFor(chain: ChainModel, address: String) throws -> ChainAccountResponse? {
        let nativeChainAccount = fetch(for: chain.accountRequest())
        if let nativeAddress = nativeChainAccount?.toAddress(), nativeAddress == address {
            return nativeChainAccount
        }

        for chainAccount in chainAccounts {
            if let chainAddress = try? chainAccount.accountId.toAddress(using: chain.chainFormat),
               let substrateCryptoType = ecosystem.substrateCryptoType,
               chainAddress == address {
                let account = ChainAccountResponse(
                    chainId: chain.chainId,
                    accountId: chainAccount.accountId,
                    publicKey: chainAccount.publicKey,
                    name: name,
                    cryptoType: CryptoType(rawValue: substrateCryptoType) ?? .sr25519,
                    addressPrefix: chain.addressPrefix,
                    ecosystem: chainAccount.ecosystem,
                    isChainAccount: true,
                    walletId: metaId
                )
                return account
            }
        }
        return nil
    }

   private func chainAccountResponse(
       for chainAccount: ChainAccountModel,
       request: ChainAccountRequest
   ) -> ChainAccountResponse? {
       guard let cryptoType = CryptoType(rawValue: chainAccount.cryptoType) else {
           return nil
       }

       return ChainAccountResponse(
           chainId: request.chainId,
           accountId: chainAccount.accountId,
           publicKey: chainAccount.publicKey,
           name: name,
           cryptoType: cryptoType,
           addressPrefix: request.addressPrefix,
           ecosystem: request.ecosystem,
           isChainAccount: true,
           walletId: metaId
       )
   }

    private func substrateResponse(for request: ChainAccountRequest) -> ChainAccountResponse? {
        guard
            let substrateCryptoType = ecosystem.substrateCryptoType,
            let cryptoType = CryptoType(rawValue: substrateCryptoType),
            let substrateAccountId = ecosystem.substrateAccountId,
            let substratePublicKey = ecosystem.substratePublicKey
        else {
            return nil
        }
        
        return ChainAccountResponse(
            chainId: request.chainId,
            accountId: substrateAccountId,
            publicKey: substratePublicKey,
            name: name,
            cryptoType: cryptoType,
            addressPrefix: request.addressPrefix,
            ecosystem: request.ecosystem,
            isChainAccount: false,
            walletId: metaId
        )
    }

    private func ethereumResponse(for request: ChainAccountRequest) -> ChainAccountResponse? {
        guard
            let publicKey = ecosystem.ethereumPublicKey,
            let accountId = ecosystem.ethereumAddress
        else {
            return nil
        }
        
        return ChainAccountResponse(
            chainId: request.chainId,
            accountId: accountId,
            publicKey: publicKey,
            name: name,
            cryptoType: .ecdsa,
            addressPrefix: request.addressPrefix,
            ecosystem: request.ecosystem,
            isChainAccount: false,
            walletId: metaId
        )
    }

    private func tonResponse(for request: ChainAccountRequest) -> ChainAccountResponse? {
        guard 
            let tonPublicKey = ecosystem.tonPublicKey,
            let tonAddress = ecosystem.tonAddress,
            let accountId = try? tonAddress.asAccountId()
        else {
            return nil
        }
        return ChainAccountResponse(
            chainId: request.chainId,
            accountId: accountId,
            publicKey: tonPublicKey,
            name: name,
            cryptoType: .ed25519,
            addressPrefix: request.addressPrefix,
            ecosystem: request.ecosystem,
            isChainAccount: false,
            walletId: metaId
        )
    }
}
