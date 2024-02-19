import Foundation
import SSFModels
import SSFRuntimeCodingService

public enum RuntimeProviderPoolError: Error {
    case missingProvider
}

public protocol RuntimeProviderPoolProtocol {
    @discardableResult
    func setupRuntimeProvider(
        for chainMetadata: RuntimeMetadataItemProtocol,
        chainTypes: Data,
        usedRuntimePaths: [String: [String]]
    ) -> RuntimeProviderProtocol
    func destroyRuntimeProvider(for chainId: ChainModel.Id)
    func getRuntimeProvider(for chainId: ChainModel.Id) throws -> RuntimeProviderProtocol
    func readySnaphot(
        for chainMetadata: RuntimeMetadataItemProtocol,
        chainTypes: Data,
        usedRuntimePaths: [String: [String]]
    ) async throws -> RuntimeSnapshot
}

public final class RuntimeProviderPool: RuntimeProviderPoolProtocol {
    private var runtimeProviders: [ChainModel.Id: RuntimeProviderProtocol] = [:]
    private let mutex = NSLock()

    public init() {}

    @discardableResult
    public func setupRuntimeProvider(
        for chainMetadata: RuntimeMetadataItemProtocol,
        chainTypes: Data,
        usedRuntimePaths: [String: [String]]
    ) -> RuntimeProviderProtocol {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        if let runtimeProvider = runtimeProviders[chainMetadata.chain] {
            return runtimeProvider
        } else {
            let operationQueue = OperationQueue()
            operationQueue.qualityOfService = .userInitiated
            let runtimeProvider = RuntimeProvider(
                operationQueue: operationQueue,
                usedRuntimePaths: usedRuntimePaths,
                chainMetadata: chainMetadata,
                chainTypes: chainTypes
            )

            runtimeProviders[chainMetadata.chain] = runtimeProvider
            runtimeProvider.setup()
            return runtimeProvider
        }
    }

    public func readySnaphot(
        for chainMetadata: RuntimeMetadataItemProtocol,
        chainTypes: Data,
        usedRuntimePaths: [String: [String]]
    ) async throws -> RuntimeSnapshot {
        if let snapshot = runtimeProviders[chainMetadata.chain]?.snapshot {
            return snapshot
        } else {
            let operationQueue = OperationQueue()
            operationQueue.qualityOfService = .userInitiated
            let runtimeProvider = RuntimeProvider(
                operationQueue: operationQueue,
                usedRuntimePaths: usedRuntimePaths,
                chainMetadata: chainMetadata,
                chainTypes: chainTypes
            )

            runtimeProviders[chainMetadata.chain] = runtimeProvider
            return try await runtimeProvider.readySnapshot()
        }
    }

    public func destroyRuntimeProvider(for chainId: ChainModel.Id) {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        let runtimeProvider = runtimeProviders[chainId]
        runtimeProvider?.cleanup()

        runtimeProviders[chainId] = nil
    }

    public func getRuntimeProvider(for chainId: ChainModel.Id) throws -> RuntimeProviderProtocol {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        guard let provider = runtimeProviders[chainId] else {
            throw RuntimeProviderPoolError.missingProvider
        }
        return provider
    }
}
