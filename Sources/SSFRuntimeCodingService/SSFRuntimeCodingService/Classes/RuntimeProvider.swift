import Foundation
import RobinHood
import SSFUtils
import SSFModels

public enum RuntimeProviderError: Error {
    case providerUnavailable
}

public final class RuntimeProvider {
    struct PendingRequest {
        let resultClosure: (RuntimeCoderFactoryProtocol?) -> Void
        let queue: DispatchQueue?
    }

    internal let chainId: ChainModel.Id
    private let chainName: String
    private let chainModel: ChainModel
    private let usedRuntimePaths: [String: [String]]

    private let snapshotOperationFactory: RuntimeSnapshotFactoryProtocol
    private let snapshotHotOperationFactory: RuntimeHotBootSnapshotFactoryProtocol?
    private let operationQueue: OperationQueue
    private let dataHasher: StorageHasher
    private let repository: AnyDataProviderRepository<RuntimeMetadataItem>

    private lazy var completionQueue: DispatchQueue = {
        DispatchQueue(
            label: "jp.co.soramitsu.fearless.fetchCoder.\(self.chainId)",
            qos: .userInitiated
        )
    }()

    public var snapshot: RuntimeSnapshot?
    private(set) var pendingRequests: [PendingRequest] = []
    private(set) var currentWrapper: BaseOperation<RuntimeSnapshot?>?
    private var mutex = NSLock()

    private var chainTypes: Data?
    private var initialChainMetadata: RuntimeMetadataItem?

    public init(
        chainModel: ChainModel,
        snapshotOperationFactory: RuntimeSnapshotFactoryProtocol,
        snapshotHotOperationFactory: RuntimeHotBootSnapshotFactoryProtocol?,
        operationQueue: OperationQueue,
        dataHasher: StorageHasher = .twox256,
        repository: AnyDataProviderRepository<RuntimeMetadataItem>,
        usedRuntimePaths: [String: [String]],
        chainMetadata: RuntimeMetadataItem?,
        chainTypes: Data?
    ) {
        chainId = chainModel.chainId
        chainName = chainModel.name
        self.chainModel = chainModel
        self.snapshotOperationFactory = snapshotOperationFactory
        self.snapshotHotOperationFactory = snapshotHotOperationFactory
        self.operationQueue = operationQueue
        self.dataHasher = dataHasher
        self.repository = repository
        self.usedRuntimePaths = usedRuntimePaths
        initialChainMetadata = chainMetadata
        self.chainTypes = chainTypes

        self.operationQueue.maxConcurrentOperationCount = 10
    }

    private func buildSnapshot(for metadata: RuntimeMetadataItem?) {
        guard
            let chainTypes = chainTypes,
            let chainMetadata = metadata
        else {
            return
        }

        let wrapper = snapshotOperationFactory.createRuntimeSnapshotWrapper(
            chainTypes: chainTypes,
            chainMetadata: chainMetadata,
            usedRuntimePaths: usedRuntimePaths
        )

        wrapper.completionBlock = { [weak self] in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.handleCompletion(result: wrapper.result)
            }
        }

        currentWrapper = wrapper

        operationQueue.addOperation(wrapper)
    }

    private func buildHotSnapshot() {
        guard let snapshotHotOperationFactory = snapshotHotOperationFactory,
              let chainTypes = chainTypes
        else {
            return
        }

        let wrapper = snapshotHotOperationFactory.createRuntimeSnapshotWrapper(
            usedRuntimePaths: usedRuntimePaths,
            chainTypes: chainTypes
        )

        wrapper.completionBlock = { [weak self] in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.handleCompletion(result: wrapper.result)
            }
        }

        currentWrapper = wrapper

        operationQueue.addOperation(wrapper)
    }

    private func handleCompletion(result: Result<RuntimeSnapshot?, Error>?) {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        switch result {
        case let .success(snapshot):
            currentWrapper = nil

            if let snapshot = snapshot {
                self.snapshot = snapshot

                resolveRequests()
            }
        case let .failure(error):
            currentWrapper = nil
        case .none:
            break
        }
    }

    private func resolveRequests() {
        guard !pendingRequests.isEmpty else {
            return
        }

        let requests = pendingRequests
        pendingRequests = []

        requests.forEach { deliver(snapshot: snapshot, to: $0) }
    }

    private func deliver(snapshot: RuntimeSnapshot?, to request: PendingRequest) {
        let coderFactory = snapshot.map {
            RuntimeCoderFactory(
                catalog: $0.typeRegistryCatalog,
                specVersion: $0.specVersion,
                txVersion: $0.txVersion,
                metadata: $0.metadata
            )
        }

        dispatchInQueueWhenPossible(request.queue) {
            request.resultClosure(coderFactory)
        }
    }

    private func fetchCoderFactory(
        runCompletionIn queue: DispatchQueue?,
        executing closure: @escaping (RuntimeCoderFactoryProtocol?) -> Void
    ) {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        let request = PendingRequest(resultClosure: closure, queue: queue)

        if let snapshot = snapshot {
            deliver(snapshot: snapshot, to: request)
        } else {
            pendingRequests.append(request)
        }
    }
}

// <<<<<<< HEAD
//    func fetchCoderFactoryOperation(
//        with _: TimeInterval,
//        closure _: RuntimeMetadataClosure?
//    ) -> BaseOperation<RuntimeCoderFactoryProtocol> {
//        AwaitOperation { [weak self] in
//            try await withCheckedThrowingContinuation { continuation in
//                self?.fetchCoderFactory(runCompletionIn: nil) { factory in
//                    guard let factory = factory else {
//                        continuation.resume(with: .failure(RuntimeProviderError.providerUnavailable))
//                        return
//                    }
//
//                    continuation.resume(with: .success(factory))
//                }
//            }
//        }
//=======

// MARK: - RuntimeProviderProtocol

extension RuntimeProvider: RuntimeProviderProtocol {
    var runtimeSnapshot: RuntimeSnapshot? {
        snapshot
    }

    public var runtimeSpecVersion: SSFRuntimeCodingService.RuntimeSpecVersion {
        runtimeSnapshot?.runtimeSpecVersion ?? RuntimeSpecVersion.defaultVersion
    }

    public func setup() {
        mutex.lock()
        defer {
            mutex.unlock()
        }

        guard currentWrapper == nil else {
            return
        }

        buildSnapshot(for: initialChainMetadata)
    }

    public func setupHot() {
        mutex.lock()
        defer {
            mutex.unlock()
        }

        guard currentWrapper == nil else {
            return
        }

        buildHotSnapshot()
    }

    public func readySnapshot() async throws -> SSFRuntimeCodingService.RuntimeSnapshot {
        guard
            let chainTypes = chainTypes,
            let chainMetadata = initialChainMetadata
        else {
            throw RuntimeProviderError.providerUnavailable
        }
        let wrapper = snapshotOperationFactory.createRuntimeSnapshotWrapper(
            chainTypes: chainTypes,
            chainMetadata: chainMetadata,
            usedRuntimePaths: usedRuntimePaths
        )
        currentWrapper = wrapper
        operationQueue.addOperation(wrapper)

        return try await withUnsafeThrowingContinuation { continuation in
            wrapper.completionBlock = { [weak self] in
                let result = wrapper.result
                self?.handleCompletion(result: result)
                switch result {
                case let .success(snapshot):
                    guard let snapshot = snapshot else {
                        return continuation.resume(throwing: RuntimeProviderError.providerUnavailable)
                    }
                    return continuation.resume(returning: snapshot)
                case let .failure(error):
                    return continuation.resume(throwing: error)
                case .none:
                    return continuation.resume(throwing: RuntimeProviderError.providerUnavailable)
                }
            }
        }
    }

    public func fetchCoderFactoryOperation() -> BaseOperation<RuntimeCoderFactoryProtocol> {
        AwaitOperation { [weak self] in
            try await withCheckedThrowingContinuation { continuation in
                self?.fetchCoderFactory(runCompletionIn: nil) { factory in
                    guard let factory = factory else {
                        continuation.resume(with: .failure(RuntimeProviderError.providerUnavailable))
                        return
                    }

                    continuation.resume(with: .success(factory))
                }
            }
        }
    }

    public func fetchCoderFactory() async throws -> RuntimeCoderFactoryProtocol {
        try await withUnsafeThrowingContinuation { continuation in
            Task {
                var nillableContinuation: UnsafeContinuation<RuntimeCoderFactoryProtocol, Error>? = continuation
                self.fetchCoderFactory(runCompletionIn: nil) { factory in
                    guard let unwrapedContinuation = nillableContinuation else {
                        return
                    }
                    guard let factory = factory else {
                        unwrapedContinuation.resume(with: .failure(RuntimeProviderError.providerUnavailable))
                        nillableContinuation = nil
                        return
                    }

                    unwrapedContinuation.resume(with: .success(factory))
                    nillableContinuation = nil
                }

                let duration = UInt64(10 * 1_000_000_000)
                try await Task.sleep(nanoseconds: duration)
                guard let unwrapedContinuation = nillableContinuation else {
                    return
                }
                unwrapedContinuation.resume(throwing: RuntimeProviderError.providerUnavailable)
                nillableContinuation = nil
            }
        }
    }

    public func cleanup() {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        snapshot = nil

        currentWrapper?.cancel()
        currentWrapper = nil

        resolveRequests()
    }
}

//extension RuntimeProvider: EventVisitorProtocol {
//    func processRuntimeChainsTypesSyncCompleted(event: RuntimeChainsTypesSyncCompleted) {
//        guard let chainTypes = event.versioningMap[chainId] else {
//            return
//        }
//
//        if let oldChainTypes = self.chainTypes,
//           let oldChainTypesJson = try? JSONDecoder().decode(JSON.self, from: oldChainTypes),
//           let updatedChainTypes = try? JSONDecoder().decode(JSON.self, from: chainTypes),
//           oldChainTypesJson.runtime_id?.unsignedIntValue == updatedChainTypes.runtime_id?.unsignedIntValue {
//            return
//        }
//
//        mutex.lock()
//
//        defer {
//            mutex.unlock()
//        }
//
//        currentWrapper?.cancel()
//        currentWrapper = nil
//
//        self.chainTypes = chainTypes
//
//        buildSnapshot(for: initialChainMetadata)
//    }
//
//    func processRuntimeChainMetadataSyncCompleted(event: RuntimeMetadataSyncCompleted) {
//        guard
//            event.chainId == chainId,
//            initialChainMetadata != event.metadata
//        else {
//            return
//        }
//
//        mutex.lock()
//
//        defer {
//            mutex.unlock()
//        }
//
//        currentWrapper?.cancel()
//        currentWrapper = nil
//
//        buildSnapshot(for: event.metadata)
//    }
//}
