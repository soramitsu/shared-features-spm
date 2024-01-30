import Foundation
import SSFExtrinsicKit
import SSFSigner
import SSFChainRegistry
import RobinHood
import SSFChainConnection
import SSFRuntimeCodingService
import SSFStorageQueryKit
import SSFUtils
import SSFModels

struct XcmDeps {
    let extrinsicService: ExtrinsicServiceProtocol
}

final class XcmDependencyContainer {
    
    private let chainRegistry: ChainRegistryProtocol
    private let fromChainData: XcmAssembly.FromChainData
    
    private var connection: SubstrateConnection?
    
    init(
        chainRegistry: ChainRegistryProtocol,
        fromChainData: XcmAssembly.FromChainData
    ) {
        self.chainRegistry = chainRegistry
        self.fromChainData = fromChainData
    }
    
    func prepareDeps() async throws -> XcmDeps {
        let operationManager = OperationManager()
        let fromChainModel = try await chainRegistry.getChain(for: fromChainData.chainId)
        let runtimeRegistry = try await chainRegistry.getRuntimeProvider(
            chainId: fromChainModel.chainId,
            usedRuntimePaths: XcmCallPath.usedRuntimePaths,
            runtimeItem: fromChainData.chainMetadata
        )
        let engine = try chainRegistry.getConnection(for: fromChainModel)
        connection = engine
        
        let extrinsicService = ExtrinsicService(
            accountId: fromChainData.accountId,
            chainFormat: fromChainModel.chainFormat,
            cryptoType: fromChainData.cryptoType,
            runtimeRegistry: runtimeRegistry,
            engine: engine,
            operationManager: operationManager
        )
        
        return XcmDeps(extrinsicService: extrinsicService)
    }
}
