import Foundation
import SSFChainRegistry
import SSFCrypto
import SSFModels
import Web3
import SSFAccountManagment

final class EthereumTransferServiceAssembly {
    func createEthereumTransferService(
        wallet: MetaAccountModel,
        chain: ChainModel,
        secretKeyData: Data,
        chainRegistry: ChainRegistryProtocol
    ) async throws -> EthereumTransferService {
        guard let accountResponse = wallet.fetch(for: chain.accountRequest()) else {
            throw TransferServiceError.accountNotExists
        }

        let connection = try chainRegistry.getEthereumConnection(for: chain)
        let privateKey = try EthereumPrivateKey(privateKey: secretKeyData.bytes)
        let address = try accountResponse.accountId.toAddress(using: .ethereum)

        let ethereumService = EthereumServiceDefault(connection: connection)

        let callFactory = EthereumTransferCallFactoryDefault(
            ethereumService: ethereumService,
            senderAddress: address,
            privateKey: privateKey
        )

        let transferService = EthereumTransferServiceDefault(
            privateKey: privateKey,
            senderAddress: address,
            callFactory: callFactory,
            ethereumService: ethereumService
        )
        return transferService
    }
}
