import Foundation
import SSFModels
import SSFRuntimeCodingService
import SSFUtils

public enum RuntimeProviderPoolError: Error {
    case missingProvider
}

public protocol RuntimeProviderPoolProtocol {
    @discardableResult
    func setupRuntimeProvider(
        for chain: ChainModel,
        chainTypes: Data?
    ) -> RuntimeProviderProtocol
    @discardableResult
    func setupHotRuntimeProvider(
        for chain: ChainModel,
        runtimeItem: RuntimeMetadataItem,
        chainTypes: Data
    ) -> RuntimeProviderProtocol
    func destroyRuntimeProvider(for chainId: ChainModel.Id)
    func getRuntimeProvider(for chainId: ChainModel.Id) -> RuntimeProviderProtocol?
}

public final class RuntimeProviderPool: RuntimeProviderPoolProtocol {
    private let runtimeProviderFactory: RuntimeProviderFactoryProtocol
    private var runtimeProviders: [ChainModel.Id: RuntimeProviderProtocol] = [:]
    private let mutex = NSLock()
    private let lock = ReaderWriterLock()
    private var usedRuntimeModules = UsedRuntimePaths()

    public init(runtimeProviderFactory: RuntimeProviderFactoryProtocol) {
        self.runtimeProviderFactory = runtimeProviderFactory
    }
    
    @discardableResult
    public func setupRuntimeProvider(
        for chain: ChainModel,
        chainTypes: Data?
    ) -> RuntimeProviderProtocol {
        if let runtimeProvider = lock.concurrentlyRead({ runtimeProviders[chain.chainId] }) {
            return runtimeProvider
        } else {
            let runtimeProvider = runtimeProviderFactory.createRuntimeProvider(
                for: chain,
                chainTypes: chainTypes,
                usedRuntimePaths: usedRuntimeModules.usedRuntimePaths
            )

            lock.exclusivelyWrite { [weak self] in
                self?.runtimeProviders[chain.chainId] = runtimeProvider
            }

            runtimeProvider.setup()
            return runtimeProvider
        }
    }
    
    @discardableResult
    public func setupHotRuntimeProvider(
        for chain: ChainModel,
        runtimeItem: RuntimeMetadataItem,
        chainTypes: Data
    ) -> RuntimeProviderProtocol {
        let runtimeProvider = runtimeProviderFactory.createHotRuntimeProvider(
            for: chain,
            runtimeItem: runtimeItem,
            chainTypes: chainTypes,
            usedRuntimePaths: usedRuntimeModules.usedRuntimePaths
        )

        lock.exclusivelyWrite { [weak self] in
            self?.runtimeProviders[chain.chainId] = runtimeProvider
        }

        runtimeProvider.setupHot()

        return runtimeProvider
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

    public func getRuntimeProvider(for chainId: ChainModel.Id) -> RuntimeProviderProtocol? {
        lock.concurrentlyRead {
            runtimeProviders[chainId]
        }
    }
}
