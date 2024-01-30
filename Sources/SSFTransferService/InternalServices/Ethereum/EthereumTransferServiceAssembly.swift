import Foundation
import Web3
import SSFModels
import SSFCrypto
import SSFChainRegistry

final class EthereumTransferServiceAssembly {
    func createEthereumTransferService(
        wallet: MetaAccountModel,
        chainAsset: ChainAsset,
        secretKeyData: Data
    ) throws -> EthereumTransferService {
        guard let accountResponse = wallet.fetch(for: chainAsset.chain.accountRequest()) else {
            throw TransferServiceError.accountNotExists
        }

        let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
        let connection = try chainRegistry.getEthereumConnection(for: chainAsset.chain)
        let privateKey = try EthereumPrivateKey(privateKey: secretKeyData.bytes)
        let address = try accountResponse.accountId.toAddress(using: .sfEthereum)
        
        let ethereumService = EthereumServiceDefault(connection: connection)
        
        let callFactory = EthereumCallFactoryDefault(
            ethereumService: ethereumService,
            chainAsset: chainAsset,
            senderAddress: address,
            privateKey: privateKey
        )

        let transferService = EthereumTransferServiceDefault(
            privateKey: privateKey,
            senderAddress: address,
            chainAsset: chainAsset,
            callFactory: callFactory,
            ethereumService: ethereumService
        )
        return transferService
    }
}
