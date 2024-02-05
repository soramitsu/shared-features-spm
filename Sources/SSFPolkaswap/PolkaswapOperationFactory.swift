import Foundation
import RobinHood
import SSFUtils
import SSFModels
import SSFPools
import SSFChainRegistry
import SSFStorageQueryKit
import SSFChainConnection

enum PolkaswapOperationFactoryError: Error {
    case unexpectedError
}

protocol PolkaswapOperationFactory {
    func dexInfos() throws -> CompoundOperationWrapper<[String]>
    func accountPools(accountId: Data, baseAssetId: String) throws -> CompoundOperationWrapper<[AccountPool]>
    func poolProperties(baseAssetId: String, targetAssetId: String) throws -> CompoundOperationWrapper<PolkaswapAccountId?>
    func poolProvidersBalance(reservesId: Data?, accountId: Data) throws -> CompoundOperationWrapper<Decimal>
    func poolTotalIssuances(reservesId: Data?) throws -> CompoundOperationWrapper<Decimal>
    func poolReserves(baseAssetId: String, targetAssetId: String) throws -> CompoundOperationWrapper<PolkaswapPoolReserves?>
    func reservesKeysOperation(baseAssetId: String) throws -> CompoundOperationWrapper<[LiquidityPair]>
}

final class PolkaswapOperationFactoryImpl {
    private let storageRequestFactory: StorageRequestFactoryProtocol
    private let chainRegistry: ChainRegistryProtocol
    private let engine: SubstrateConnection
    private let chain: ChainModel
    
    public init(
        storageRequestFactory: StorageRequestFactoryProtocol,
        chainRegistry: ChainRegistryProtocol,
        engine: SubstrateConnection,
        chain: ChainModel
    ) {
        self.storageRequestFactory = storageRequestFactory
        self.chainRegistry = chainRegistry
        self.engine = engine
        self.chain = chain
    }
}
extension PolkaswapOperationFactoryImpl: PolkaswapOperationFactory {
    func dexInfos() throws -> CompoundOperationWrapper<[String]> {
        guard let runtimeProvider = chainRegistry.getRuntimeProvider(for: chain.chainId) else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.runtimeMetadaUnavailable)
        }
        
        let fetchCoderFactoryOperation = runtimeProvider.fetchCoderFactoryOperation()
        
        let storageOperation: CompoundOperationWrapper<[StorageResponse<DexInfos>]> =
        storageRequestFactory.queryItemsByPrefix(
            engine: engine,
            keys: { [ try StorageKeyFactory().key(from: .polkaswapDexManagerDesInfos) ] },
            factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
            storagePath: StorageCodingPath.polkaswapDexManagerDesInfos
        )
        
        storageOperation.allOperations.forEach { $0.addDependency(fetchCoderFactoryOperation) }

        let mapOperation = ClosureOperation<[String]> {
            let response = try storageOperation.targetOperation.extractNoCancellableResultData()
            return response.compactMap { $0.value?.baseAssetId.code }
        }

        mapOperation.addDependency(storageOperation.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + storageOperation.allOperations
        )
    }
    
    func accountPools(accountId: Data, baseAssetId: String) throws -> CompoundOperationWrapper<[AccountPool]> {
        guard let runtimeOperation = chainRegistry.getRuntimeProvider(for: chain.chainId)
        else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.runtimeMetadaUnavailable)
        }
            
        let fetchCoderFactoryOperation = runtimeOperation.fetchCoderFactoryOperation()

        let storageOperation: CompoundOperationWrapper<[StorageResponse<[PolkaswapDexInfoAssetId]>]> =
        storageRequestFactory.queryItems(
            engine: engine,
            keyParams: {
                [
                    [ NMapKeyParam(value: accountId) ],
                    [ NMapKeyParam(value: PolkaswapDexInfoAssetId(code: baseAssetId)) ]
                ]
            },
            factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
            storagePath: StorageCodingPath.polkaswapUserPools
        )
        
        storageOperation.allOperations.forEach { $0.addDependency(fetchCoderFactoryOperation) }

        let mapOperation = ClosureOperation<[AccountPool]> { [weak self] in
            guard let chainId = self?.chain.chainId else {
                throw PolkaswapOperationFactoryError.unexpectedError
            }

            let result = try storageOperation.targetOperation.extractNoCancellableResultData().first?.value ?? []
            return result.map { 
                let poolId = [ Data(baseAssetId.utf8), Data($0.code.utf8), Data(accountId), Data(chainId.utf8) ].createId()
                return AccountPool(
                    poolId: poolId,
                    accountId: accountId.toHex(),
                    chainId: chainId,
                    baseAssetId: baseAssetId,
                    targetAssetId: $0.code
                )
            }
        }

        mapOperation.addDependency(storageOperation.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + storageOperation.allOperations
        )
    }
    
    func poolProperties(baseAssetId: String, targetAssetId: String) throws -> CompoundOperationWrapper<PolkaswapAccountId?> {
        guard let runtimeOperation = chainRegistry.getRuntimeProvider(for: chain.chainId) else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.runtimeMetadaUnavailable)
        }
            
        let fetchCoderFactoryOperation = runtimeOperation.fetchCoderFactoryOperation()

        let storageOperation: CompoundOperationWrapper<[StorageResponse<[Data]>]> =
        storageRequestFactory.queryItems(
            engine: engine,
            keyParams: {
                [
                    [ NMapKeyParam(value: PolkaswapDexInfoAssetId(code: baseAssetId)) ],
                    [ NMapKeyParam(value: PolkaswapDexInfoAssetId(code: targetAssetId)) ]
                ]
            },
            factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
            storagePath: StorageCodingPath.polkaswapPoolProperties
        )
        
        storageOperation.allOperations.forEach { $0.addDependency(fetchCoderFactoryOperation) }

        let mapOperation = ClosureOperation<PolkaswapAccountId?> {
            let storageResponse = try storageOperation.targetOperation.extractNoCancellableResultData().first?.value?.first
            let decoder = try ScaleDecoder(data: storageResponse ?? Data())
            let accountId = try PolkaswapAccountId(scaleDecoder: decoder)
            return accountId
        }

        mapOperation.addDependency(storageOperation.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + storageOperation.allOperations
        )
    }
    
    func poolProvidersBalance(reservesId: Data?, accountId: Data) throws -> CompoundOperationWrapper<Decimal> {
        guard let runtimeOperation = chainRegistry.getRuntimeProvider(for: chain.chainId)
        else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.runtimeMetadaUnavailable)
        }

        let fetchCoderFactoryOperation = runtimeOperation.fetchCoderFactoryOperation()

        let storageOperation: CompoundOperationWrapper<[StorageResponse<SoraAmountDecimal>]> =
        storageRequestFactory.queryItems(
            engine: engine,
            keyParams: {
                [
                    [ NMapKeyParam(value: reservesId) ],
                    [ NMapKeyParam(value: accountId) ]
                ]
            },
            factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
            storagePath: StorageCodingPath.polkaswapPoolProviders
        )
        
        storageOperation.allOperations.forEach { $0.addDependency(fetchCoderFactoryOperation) }

        let mapOperation = ClosureOperation<Decimal> {
            try storageOperation.targetOperation.extractNoCancellableResultData().first?.value?.decimalValue ?? Decimal(0)
        }

        mapOperation.addDependency(storageOperation.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + storageOperation.allOperations
        )
    }
    
    func poolTotalIssuances(reservesId: Data?) throws -> CompoundOperationWrapper<Decimal> {
        guard let runtimeOperation = chainRegistry.getRuntimeProvider(for: chain.chainId) else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.runtimeMetadaUnavailable)
        }
            
        let fetchCoderFactoryOperation = runtimeOperation.fetchCoderFactoryOperation()

        let storageOperation: CompoundOperationWrapper<[StorageResponse<SoraAmountDecimal>]> =
        storageRequestFactory.queryItems(
            engine: engine,
            keyParams: { [ reservesId ] },
            factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
            storagePath: StorageCodingPath.polkaswapPoolTotalIssuances
        )
        
        storageOperation.allOperations.forEach { $0.addDependency(fetchCoderFactoryOperation) }

        let mapOperation = ClosureOperation<Decimal> {
            try storageOperation.targetOperation.extractNoCancellableResultData().first?.value?.decimalValue ?? Decimal(0)
        }

        mapOperation.addDependency(storageOperation.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + storageOperation.allOperations
        )
    }
    
    func reservesKeysOperation(baseAssetId: String) throws -> CompoundOperationWrapper<[LiquidityPair]> {
        guard let runtimeOperation = chainRegistry.getRuntimeProvider(for: chain.chainId) else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.connectionUnavailable)
        }
        
        let fetchCoderFactoryOperation = runtimeOperation.fetchCoderFactoryOperation()
        
        let key = try StorageKeyFactory().xykPoolKeyReserves(asset: Data(hexStringSSF: baseAssetId))

        let dexInfosWrapper: CompoundOperationWrapper<[StorageResponse<[SoraAmountDecimal]>]> =
            storageRequestFactory.queryItemsByPrefix(
                engine: engine,
                keys: { [ key ] },
                factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
                storagePath: StorageCodingPath.polkaswapPoolReserves
            )

        let mapOperation = ClosureOperation<[LiquidityPair]> { [weak self] in
            guard let chainId = self?.chain.chainId else {
                throw PolkaswapOperationFactoryError.unexpectedError
            }

            let storageResponse = try? dexInfosWrapper.targetOperation.extractNoCancellableResultData()
                
            let reservesInfo = storageResponse?.compactMap { response in
                let targetAssetId = response.key.toHex().assetIdFromKey()
                let pairId = [ Data(baseAssetId.utf8), Data(targetAssetId.utf8), Data(chainId.utf8) ].createId()
                return LiquidityPair(
                    pairId: pairId,
                    chainId: chainId,
                    baseAssetId: baseAssetId,
                    targetAssetId: targetAssetId,
                    reserves: response.value?.first?.decimalValue
                )
            }

            return reservesInfo ?? []
        }

        mapOperation.addDependency(dexInfosWrapper.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + dexInfosWrapper.allOperations
        )
    }
    
    func poolReserves(baseAssetId: String, targetAssetId: String) throws -> CompoundOperationWrapper<PolkaswapPoolReserves?> {
        guard let runtimeOperation = chainRegistry.getRuntimeProvider(for: chain.chainId) else {
            return CompoundOperationWrapper.createWithError(ChainRegistryError.connectionUnavailable)
        }

        let fetchCoderFactoryOperation = runtimeOperation.fetchCoderFactoryOperation()

        let storageOperation: CompoundOperationWrapper<[StorageResponse<[SoraAmountDecimal]>]> =
        storageRequestFactory.queryItems(
            engine: engine,
            keyParams: {
                [
                    [ NMapKeyParam(value: PolkaswapDexInfoAssetId(code: baseAssetId)) ],
                    [ NMapKeyParam(value: PolkaswapDexInfoAssetId(code: targetAssetId)) ]
                ]
            },
            factory: { try fetchCoderFactoryOperation.extractNoCancellableResultData() },
            storagePath: StorageCodingPath.polkaswapPoolReserves
        )
        
        storageOperation.allOperations.forEach { $0.addDependency(fetchCoderFactoryOperation) }

        let mapOperation = ClosureOperation<PolkaswapPoolReserves?> {
            let response = try? storageOperation.targetOperation.extractNoCancellableResultData().first?.value ?? []
            return PolkaswapPoolReserves(reserves: response?.first?.decimalValue, fees: response?.last?.decimalValue)
        }

        mapOperation.addDependency(storageOperation.targetOperation)

        return CompoundOperationWrapper(
            targetOperation: mapOperation,
            dependencies: [fetchCoderFactoryOperation] + storageOperation.allOperations
        )
    }
}

extension JSONRPCOperation {
    public static func failureOperation(_ error: Error) -> JSONRPCOperation<P, T> {
        let mockEngine = WebSocketEngine(connectionName: nil, url: URL(string: "https://wiki.fearlesswallet.io")!, autoconnect: false)
        let operation = JSONRPCOperation<P, T>(engine: mockEngine, method: "")
        operation.result = .failure(error)
        return operation
    }
}
