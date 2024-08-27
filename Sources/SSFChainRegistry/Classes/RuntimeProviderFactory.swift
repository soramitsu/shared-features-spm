import Foundation
import RobinHood
import SSFModels
import SSFRuntimeCodingService
import SSFUtils

public protocol RuntimeProviderFactoryProtocol {
    func createRuntimeProvider(
        for chain: ChainModel,
        chainTypes: Data?,
        usedRuntimePaths: [String: [String]]
    ) -> RuntimeProviderProtocol

    func createHotRuntimeProvider(
        for chain: ChainModel,
        runtimeItem: RuntimeMetadataItem,
        chainTypes: Data,
        usedRuntimePaths: [String: [String]]
    ) -> RuntimeProviderProtocol
}

final class RuntimeProviderFactory {
    let fileOperationFactory: RuntimeFilesOperationFactoryProtocol
    let repository: AnyDataProviderRepository<RuntimeMetadataItem>
    let dataOperationFactory: DataOperationFactoryProtocol
    let operationQueue: OperationQueue

    init(
        fileOperationFactory: RuntimeFilesOperationFactoryProtocol,
        repository: AnyDataProviderRepository<RuntimeMetadataItem>,
        dataOperationFactory: DataOperationFactoryProtocol,
        operationQueue: OperationQueue
    ) {
        self.fileOperationFactory = fileOperationFactory
        self.repository = repository
        self.dataOperationFactory = dataOperationFactory
        self.operationQueue = operationQueue
    }
}

extension RuntimeProviderFactory: RuntimeProviderFactoryProtocol {
    func createRuntimeProvider(
        for chain: ChainModel,
        chainTypes: Data?,
        usedRuntimePaths: [String: [String]]
    ) -> RuntimeProviderProtocol {
        let snapshotOperationFactory = RuntimeSnapshotFactory(
            chainId: chain.chainId,
            filesOperationFactory: fileOperationFactory,
            repository: repository
        )

        return RuntimeProvider(
            chainModel: chain,
            snapshotOperationFactory: snapshotOperationFactory,
            snapshotHotOperationFactory: nil,
            operationQueue: operationQueue,
            repository: repository,
            usedRuntimePaths: usedRuntimePaths,
            chainMetadata: nil,
            chainTypes: chainTypes
        )
    }

    func createHotRuntimeProvider(
        for chain: ChainModel,
        runtimeItem: RuntimeMetadataItem,
        chainTypes: Data,
        usedRuntimePaths: [String: [String]]
    ) -> RuntimeProviderProtocol {
        let snapshotOperationFactory = RuntimeSnapshotFactory(
            chainId: chain.chainId,
            filesOperationFactory: fileOperationFactory,
            repository: repository
        )

        let snapshotHotOperationFactory = RuntimeHotBootSnapshotFactory(
            chainId: chain.chainId,
            runtimeItem: runtimeItem,
            filesOperationFactory: fileOperationFactory
        )

        return RuntimeProvider(
            chainModel: chain,
            snapshotOperationFactory: snapshotOperationFactory,
            snapshotHotOperationFactory: snapshotHotOperationFactory,
            operationQueue: operationQueue,
            repository: repository,
            usedRuntimePaths: usedRuntimePaths,
            chainMetadata: runtimeItem,
            chainTypes: chainTypes
        )
    }
}
