import Foundation
import SSFExtrinsicKit
import SSFModels
import SSFCrypto
import SSFRuntimeCodingService
import SSFUtils
import RobinHood
import SSFSigner
import SSFStorageQueryKit
import SSFChainConnection
import SSFNetwork
import SSFChainRegistry

public struct XcmExtrinsicServices {
    public let extrinsic: XcmExtrinsicServiceProtocol
    public let destinationFeeFetcher: XcmDestinationFeeFetching
    public let availableDestionationFetching: XcmChainsConfigFetching
}

final public class XcmAssembly {
    
    public static func createExtrincisServices(
        fromChainData: FromChainData,
        sourceConfig: XcmConfigProtocol?
    ) -> XcmExtrinsicServices {
        let operationManager = OperationManager()
        
        let signingWrapper = TransactionSigner(
            publicKeyData: fromChainData.signingWrapperData.publicKeyData,
            secretKeyData: fromChainData.signingWrapperData.secretKeyData,
            cryptoType: fromChainData.cryptoType
        )
        
        let extrinsicBuilder = XcmExtrinsicBuilder()
        
        let chainSyncService = ChainSyncService(
            chainsUrl: sourceConfig?.chainsSourceUrl ?? XcmConfig.shared.chainsSourceUrl,
            operationQueue: OperationQueue(),
            dataFetchFactory: NetworkOperationFactory()
        )
        
        let chainsTypesSyncService = ChainsTypesSyncService(
            url: sourceConfig?.chainTypesSourceUrl ?? XcmConfig.shared.chainTypesSourceUrl,
            dataOperationFactory: NetworkOperationFactory(),
            operationQueue: OperationQueue()
        )
        
        let runtimeSyncService = RuntimeSyncService(dataOperationFactory: NetworkOperationFactory())
        
        let chainRegistry = ChainRegistry(
            runtimeProviderPool: RuntimeProviderPool(),
            connectionPool: ConnectionPool(),
            chainSyncService: chainSyncService,
            chainsTypesSyncService: chainsTypesSyncService,
            runtimeSyncService: runtimeSyncService
        )
        
        let xcmChainsConfigFetcher = XcmChainsConfigFetcher(chainRegistry: chainRegistry)
        let depsContainer = XcmDependencyContainer(
            chainRegistry: chainRegistry,
            fromChainData: fromChainData
        )
        
        let callPathDeterminer = CallPathDeterminerImpl(
            chainRegistry: chainRegistry,
            fromChainData: fromChainData
        )
        
        let destinationFeeFetcher = XcmDestinationFeeFetcher(
            sourceUrl: sourceConfig?.destinationFeeSourceUrl ?? XcmConfig.shared.destinationFeeSourceUrl,
            networkOperationFactory: NetworkOperationFactory(),
            operationQueue: OperationQueue()
        )
        
        let extrinsic = XcmExtrinsicService(
            signingWrapper: signingWrapper,
            extrinsicBuilder: extrinsicBuilder,
            xcmVersionFetcher: xcmChainsConfigFetcher,
            chainRegistry: chainRegistry,
            depsContainer: depsContainer,
            operationManager: operationManager,
            callPathDeterminer: callPathDeterminer,
            xcmFeeFetcher: destinationFeeFetcher
        )
        
        return XcmExtrinsicServices(
            extrinsic: extrinsic,
            destinationFeeFetcher: destinationFeeFetcher,
            availableDestionationFetching: xcmChainsConfigFetcher
        )
    }
}

extension XcmAssembly {
    public struct SigningWrapperData: Equatable {
        public let publicKeyData: Data
        public let secretKeyData: Data
        
        public init(publicKeyData: Data, secretKeyData: Data) {
            self.publicKeyData = publicKeyData
            self.secretKeyData = secretKeyData
        }
    }
    
    public struct FromChainData {
        public let chainId: String
        public let cryptoType: SFCryptoType
        public let chainMetadata: RuntimeMetadataItemProtocol?
        public let accountId: AccountId
        public let signingWrapperData: SigningWrapperData
        
        public init(
            chainId: String,
            cryptoType: SFCryptoType,
            chainMetadata: RuntimeMetadataItemProtocol?,
            accountId: AccountId,
            signingWrapperData: XcmAssembly.SigningWrapperData
        ) {
            self.chainId = chainId
            self.cryptoType = cryptoType
            self.chainMetadata = chainMetadata
            self.accountId = accountId
            self.signingWrapperData = signingWrapperData
        }
    }
}
