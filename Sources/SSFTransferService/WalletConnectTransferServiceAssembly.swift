import Foundation
import SSFChainRegistry
import Web3
import SSFModels

public class WalletConnectTransferServiceAssembly {
    public func createService(privateKey: Data, chain: ChainModel) throws -> WalletConnectTransferService {
        let chainRegistry = ChainRegistryAssembly.createDefaultRegistry()
        let connection = try chainRegistry.getEthereumConnection(for: chain)
        let privateKey = try EthereumPrivateKey(privateKey: privateKey.bytes)
        let ethereumService = EthereumServiceDefault(connection: connection)
        
        let service = WalletConnectTransferServiceDefault(
            privateKey: privateKey,
            ethereumService: ethereumService
        )
        return service
    }
}
