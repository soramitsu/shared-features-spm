import IrohaCrypto
import SSFCrypto

public protocol TransactionSignerProtocol: IRSignatureCreatorProtocol {}

extension TransactionSignerProtocol {
    func signSr25519(
        _ originalData: Data,
        secretKeyData: Data,
        publicKeyData: Data
    ) throws
        -> IRSignatureProtocol {
        let privateKey = try SNPrivateKey(rawData: secretKeyData)
        let publicKey = try SNPublicKey(rawData: publicKeyData)

        let signer = SNSigner(keypair: SNKeypair(privateKey: privateKey, publicKey: publicKey))
        let signature = try signer.sign(originalData)

        return signature
    }

    func signEd25519(
        _ originalData: Data,
        secretKey: Data
    ) throws -> IRSignatureProtocol {
        let keypairFactory = Ed25519KeypairFactory()
        let privateKey = try keypairFactory
            .createKeypairFromSeed(secretKey.miniSeed, chaincodeList: [])
            .privateKey()

        let signer = EDSigner(privateKey: privateKey)

        return try signer.sign(originalData)
    }

    func signEcdsa(
        _ originalData: Data,
        secretKey: Data
    ) throws -> IRSignatureProtocol {
        let keypairFactory = EcdsaKeypairFactory()
        let privateKey = try keypairFactory
            .createKeypairFromSeed(secretKey.miniSeed, chaincodeList: [])
            .privateKey()

        let signer = SECSigner(privateKey: privateKey)

        let hashedData = try originalData.blake2b32()
        return try signer.sign(hashedData)
    }

    func signEthereumEcdsa(
        _ originalData: Data,
        secretKey: Data
    ) throws -> IRSignatureProtocol {
        let keypairFactory = EcdsaKeypairFactory()
        let privateKey = try keypairFactory
            .createKeypairFromSeed(secretKey.miniSeed, chaincodeList: [])
            .privateKey()

        let signer = SECSigner(privateKey: privateKey)

        let hashedData = try originalData.keccak256()
        return try signer.sign(hashedData)
    }
}

final public class TransactionSigner: TransactionSignerProtocol {
    
    private let publicKeyData: Data
    private let secretKeyData: Data
    private let cryptoType: SFCryptoType
    
    public init(
        publicKeyData: Data,
        secretKeyData: Data,
        cryptoType: SFCryptoType
    ) {
        self.publicKeyData = publicKeyData
        self.secretKeyData = secretKeyData
        self.cryptoType = cryptoType
    }
    
    public func sign(_ originalData: Data) throws -> IRSignatureProtocol {
        switch cryptoType {
        case .sr25519:
            return try signSr25519(
                originalData,
                secretKeyData: secretKeyData,
                publicKeyData: publicKeyData
            )
        case .ed25519:
            return try signEd25519(
                originalData,
                secretKey: secretKeyData
            )
        case .ecdsa:
            return try signEcdsa(
                originalData,
                secretKey: secretKeyData
            )
        case .ethereumEcdsa:
            return try signEthereumEcdsa(
                originalData,
                secretKey: secretKeyData
            )
        }
    }
}
