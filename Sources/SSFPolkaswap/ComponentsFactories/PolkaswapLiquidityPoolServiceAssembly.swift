import Foundation
import SSFModels
import SSFStorageQueryKit
import SSFChainRegistry
import sorawallet
import SSFRuntimeCodingService
import SSFExtrinsicKit
import SSFAccountManagment
import SSFSigner
import SSFUtils

public final class PolkaswapLiquidityPoolServiceAssembly {
    public static func buildService(for chain: ChainModel, chainRegistry: ChainRegistryProtocol) -> PolkaswapLiquidityPoolService {
        let storageRequestPerformer = StorageRequestPerformerDefault(chainRegistry: chainRegistry)
        let dexManagerStorage = DexManagerStorageDefault(storageRequestPerformer: storageRequestPerformer)
        let poolXykStorage = PoolXykStorageDefaultL(storageRequestPerformer: storageRequestPerformer)
        let apyFetcher = PoolsApyFetcherDefault(url: chain.externalApi?.pricing?.url)
        
        return PolkaswapLiquidityPoolServiceDefault(
            dexManagerStorage: dexManagerStorage,
            poolXykStorage: poolXykStorage,
            chain: chain,
            apyFetcher: apyFetcher
        )
    }
    
    public static func buildOperationService(
        for chain: ChainModel,
        wallet: MetaAccountModel,
        chainRegistry: ChainRegistryProtocol,
        signingWrapperData: SigningWrapperData
    ) throws -> PolkaswapLiquidityPoolOperationService {
        guard
            let account = wallet.fetch(for: chain.accountRequest()),
            let runtimeService = chainRegistry.getRuntimeProvider(for: chain.chainId)
        else {
            throw ChainAccountFetchingError.accountNotExists
        }
        
        let connection = try chainRegistry.getSubstrateConnection(for: chain)
        let extrinsicBuilder = PolkaswapExtrinsicBuilder(callFactory: SubstrateCallFactoryDefault())
        let extrinsicService = ExtrinsicService(
            accountId: account.accountId,
            chainFormat: chain.chainFormat,
            cryptoType: account.cryptoType,
            runtimeRegistry: runtimeService,
            engine: connection,
            operationManager: OperationManagerFacade.sharedManager
        )
        
        let signer = try TransactionSignerAssembly.signer(
            for: chain.ecosystem,
            publicKeyData: signingWrapperData.publicKeyData,
            secretKeyData: signingWrapperData.secretKeyData,
            cryptoType: account.cryptoType
        )
        
        let poolsService = buildService(for: chain, chainRegistry: chainRegistry)
        return PolkaswapLiquidityPoolOperationService(extrinsicBuilder: extrinsicBuilder, extrisicService: extrinsicService, signingWrapper: signer, poolService: poolsService)
    }
}
