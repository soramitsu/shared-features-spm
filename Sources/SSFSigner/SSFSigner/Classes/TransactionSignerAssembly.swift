import Foundation
import SSFModels

public enum TransactionSignerAssemblyError: Error {
    case unsupportedEcossytem
}

public enum TransactionSignerAssembly {
    public static func signer(
        for ecosystem: Ecosystem,
        publicKeyData: Data,
        secretKeyData: Data,
        cryptoType: CryptoType
    ) throws -> TransactionSignerProtocol {
        switch ecosystem {
        case .substrate:
            return SubstrateTransactionSigner(
                publicKeyData: publicKeyData,
                secretKeyData: secretKeyData,
                cryptoType: cryptoType
            )
        case .ethereum, .ethereumBased:
            return EthereumTransactionSigner(
                publicKeyData: publicKeyData,
                secretKeyData: secretKeyData
            )
        case .ton:
            throw TransactionSignerAssemblyError.unsupportedEcossytem
        }
    }
}
