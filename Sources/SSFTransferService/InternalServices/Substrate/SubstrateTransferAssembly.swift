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
        chainAsset: ChainAsset,
        secretKeyData: Data
    ) async throws -> SubstrateTransferService {
        guard let accountResponse = wallet.fetch(for: chainAsset.chain.accountRequest()) else {
            throw TransferServiceError.accountNotExists
        }

        let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
        let connection = try chainRegistry.getConnection(for: chainAsset.chain)

        let runtimeService = try await chainRegistry.getRuntimeProvider(
            chainId: chainAsset.chain.chainId,
            usedRuntimePaths: [:],
            runtimeItem: nil
        )

        let operationManager = OperationManagerFacade.sharedManager
        
        let cryptoType = SFCryptoType(accountResponse.cryptoType)
        let extrinsicService = SSFExtrinsicKit.ExtrinsicService(
            accountId: accountResponse.accountId,
            chainFormat: chainAsset.chain.chainFormat,
            cryptoType: cryptoType,
            runtimeRegistry: runtimeService,
            engine: connection,
            operationManager: operationManager
        )
        
        let callFactory = SubstrateCallFactoryDefault(runtimeService: runtimeService)
        let signer = TransactionSigner(
            publicKeyData: accountResponse.publicKey,
            secretKeyData: secretKeyData,
            cryptoType: cryptoType
        )
        return SubstrateTransferServiceDefault(
            extrinsicService: extrinsicService,
            callFactory: callFactory,
            signer: signer,
            chainAsset: chainAsset
        )
    }
}
