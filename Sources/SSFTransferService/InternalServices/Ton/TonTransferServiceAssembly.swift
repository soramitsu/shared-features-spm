import Foundation
import SSFChainRegistry

struct TonTransferServiceAssembly {
    static func createService(
        chainRegistry: ChainRegistryProtocol,
        secretKey: Data
    ) -> TonTransferService {
        let tonService = TonSendServiceDefault(
            chainRegistry: chainRegistry
        )
        let bocFactory = BocFactoryImpl(secretKey: secretKey)
        let transferService = TonTransferServiceImpl(
            service: tonService,
            bocFactory: bocFactory
        )
        return transferService
    }
}
