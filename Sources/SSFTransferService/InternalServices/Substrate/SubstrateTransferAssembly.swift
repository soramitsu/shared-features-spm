import Foundation
import SSFExtrinsicKit
import SSFModels
import SSFChainConnection
import SSFChainRegistry
import SSFNetwork
import SSFCrypto
import SSFSigner
import SSFUtils

final class SubstrateTransferAssembly {
    
    func createSubstrateService(
        wallet: MetaAccountModel,
        chain: ChainModel,
        secretKeyData: Data
    ) async throws -> SubstrateTransferService {
        guard let accountResponse = wallet.fetch(for: chain.accountRequest()) else {
            throw TransferServiceError.accountNotExists
        }

        let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
        let connection = try await chainRegistry.getSubstrateConnection(for: chain)

        let runtimeService = try await chainRegistry.getRuntimeProvider(
            chainId: chain.chainId,
            usedRuntimePaths: [:],
            runtimeItem: nil
        )

        let operationManager = OperationManagerFacade.sharedManager
        
        let cryptoType = SFCryptoType(accountResponse.cryptoType)
        let extrinsicService = SSFExtrinsicKit.ExtrinsicService(
            accountId: accountResponse.accountId,
            chainFormat: chain.chainFormat,
            cryptoType: cryptoType,
            runtimeRegistry: runtimeService,
            engine: connection,
            operationManager: operationManager
        )
        
        let callFactory = SubstrateTransferCallFactoryDefault(runtimeService: runtimeService)
        let signer = TransactionSigner(
            publicKeyData: accountResponse.publicKey,
            secretKeyData: secretKeyData,
            cryptoType: cryptoType
        )
        return SubstrateTransferServiceDefault(
            extrinsicService: extrinsicService,
            callFactory: callFactory,
            signer: signer
        )
    }
}
