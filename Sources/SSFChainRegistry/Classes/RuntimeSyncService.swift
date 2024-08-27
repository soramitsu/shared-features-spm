import Foundation
import RobinHood
import SSFChainConnection
import SSFModels
import SSFNetwork
import SSFUtils

public protocol RuntimeSyncServiceProtocol {
    func register(chain: ChainModel, with connection: SubstrateConnection) async
    func unregister(chainId: ChainModel.Id) async
    func apply(version: RuntimeVersion, for chainId: ChainModel.Id) async
    func hasChain(with chainId: ChainModel.Id) async -> Bool
    func isChainSyncing(_ chainId: ChainModel.Id) async -> Bool
}

public enum RuntimeSyncServiceError: Error {
    case skipMetadataUnchanged
    case runtimeItemsNotLoaded
    case missingRuntimeItem
    case missingConnection
    case missingRuntimeVersionResult
}

public actor RuntimeSyncService {
    struct SyncResult {
        let chainId: ChainModel.Id
        let metadataSyncResult: Result<RuntimeMetadataItem?, Error>?
        let runtimeVersion: RuntimeVersion?
    }

    struct RetryAttempt {
        let chainId: ChainModel.Id
        let runtimeVersion: RuntimeVersion?
        let attempt: Int
    }

    private let dataOperationFactory: NetworkOperationFactoryProtocol
    private let retryStrategy: ReconnectionStrategyProtocol
    private let operationQueue: OperationQueue

    private var mutex = NSLock()
    private var retryScheduler: Scheduler?

    private var knownChains: [ChainModel.Id: SubstrateConnection] = [:]
    private var syncingChains: [ChainModel.Id: CompoundOperationWrapper<SyncResult>] = [:]
    private var metadataItems: [ChainModel.Id: RuntimeMetadataItem] = [:]
    private var retryAttempts: [ChainModel.Id: RetryAttempt] = [:]
    private var errors: [ChainModel.Id: Error] = [:]

    public init(
        dataOperationFactory: NetworkOperationFactoryProtocol,
        retryStrategy: ReconnectionStrategyProtocol = ExponentialReconnection()
    ) {
        self.dataOperationFactory = dataOperationFactory
        self.retryStrategy = retryStrategy

        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        self.operationQueue = operationQueue
    }

    private func performSync(
        for chainId: ChainModel.Id,
        newVersion: RuntimeVersion? = nil
    ) {
        guard let connection = knownChains[chainId] else {
            return
        }

        let metadataSyncWrapper = newVersion.map {
            createMetadataSyncOperation(
                for: chainId,
                runtimeVersion: $0,
                connection: connection
            )
        }

        if metadataSyncWrapper == nil {
            return
        }

        let dependencies = (metadataSyncWrapper?.allOperations ?? [])

        let processingOperation = ClosureOperation<SyncResult> {
            SyncResult(
                chainId: chainId,
                metadataSyncResult: metadataSyncWrapper?.targetOperation.result,
                runtimeVersion: newVersion
            )
        }

        dependencies.forEach { processingOperation.addDependency($0) }

        processingOperation.completionBlock = { [weak self] in
            Task {
                do {
                    let result = try processingOperation.extractNoCancellableResultData()
                    await self?.processSyncResult(result)
                } catch let error as BaseOperationError where error == .parentOperationCancelled {
                    return
                } catch {
                    let result = SyncResult(
                        chainId: chainId,
                        metadataSyncResult: .failure(error),
                        runtimeVersion: newVersion
                    )

                    await self?.processSyncResult(result)
                }
            }
        }

        let wrapper = CompoundOperationWrapper(
            targetOperation: processingOperation,
            dependencies: dependencies
        )

        syncingChains[chainId] = wrapper

        operationQueue.addOperations(wrapper.allOperations, waitUntilFinished: false)
    }

    private func processSyncResult(_ result: SyncResult) async {
        syncingChains[result.chainId] = nil
        addRetryRequestIfNeeded(for: result)
        notifyCompletion(for: result)
    }

    private func addRetryRequestIfNeeded(for result: SyncResult) {
        let runtimeSyncVersion: RuntimeVersion?

        if let version = result.runtimeVersion, case .failure = result.metadataSyncResult {
            runtimeSyncVersion = version
        } else {
            runtimeSyncVersion = nil
        }

        if runtimeSyncVersion != nil {
            let nextAttempt = retryAttempts[result.chainId].map { $0.attempt + 1 } ?? 1

            let retryAttempt = RetryAttempt(
                chainId: result.chainId,
                runtimeVersion: runtimeSyncVersion,
                attempt: nextAttempt
            )

            retryAttempts[result.chainId] = retryAttempt

            rescheduleRetryIfNeeded()
        } else {
            retryAttempts[result.chainId] = nil
        }
    }

    private func rescheduleRetryIfNeeded() {
        guard retryScheduler == nil else {
            return
        }

        guard let maxAttempt = retryAttempts.max(by: { $0.value.attempt < $1.value.attempt })?
            .value.attempt else
        {
            return
        }

        if let delay = retryStrategy.reconnectAfter(attempt: maxAttempt) {
            retryScheduler = Scheduler(with: self)
            retryScheduler?.notifyAfter(delay)
        }
    }

    private func notifyCompletion(for result: SyncResult) {
        if case .success = result.metadataSyncResult,
           let metadata = try? result.metadataSyncResult?.get()
        {
            metadataItems[result.chainId] = metadata
        }
    }

    private func createMetadataSyncOperation(
        for chainId: ChainModel.Id,
        runtimeVersion: RuntimeVersion,
        connection: JSONRPCEngine
    ) -> CompoundOperationWrapper<RuntimeMetadataItem?> {
        let remoteMetadaOperation = JSONRPCOperation<[String], String>(
            engine: connection,
            method: RPCMethod.getRuntimeMetadata
        )

        let buildRuntimeMetadataOperation = ClosureOperation<RuntimeMetadataItem> {
            let hexMetadata = try remoteMetadaOperation.extractNoCancellableResultData()
            let rawMetadata = try Data(hexStringSSF: hexMetadata)
            let metadataItem = RuntimeMetadataItem(
                chain: chainId,
                version: runtimeVersion.specVersion,
                txVersion: runtimeVersion.transactionVersion,
                metadata: rawMetadata
            )

            return metadataItem
        }

        let filterOperation = ClosureOperation<RuntimeMetadataItem?> {
            do {
                let metadataItem = try buildRuntimeMetadataOperation
                    .extractNoCancellableResultData()
                return metadataItem
            } catch let error as RuntimeSyncServiceError where error == .skipMetadataUnchanged {
                return nil
            }
        }

        buildRuntimeMetadataOperation.addDependency(remoteMetadaOperation)
        filterOperation.addDependency(buildRuntimeMetadataOperation)

        return CompoundOperationWrapper(
            targetOperation: filterOperation,
            dependencies: [
                remoteMetadaOperation,
                buildRuntimeMetadataOperation,
            ]
        )
    }

    private func getRemoteRuntimeVersion(with connection: SubstrateConnection) async throws
        -> RuntimeVersion
    {
        let remoteRuntimeVersionOperation = JSONRPCOperation<[String], RuntimeVersion>(
            engine: connection,
            method: RPCMethod.getRuntimeVersion
        )

        let operationQueue = OperationQueue()
        operationQueue.addOperation(remoteRuntimeVersionOperation)

        return try await withUnsafeThrowingContinuation { continuation in
            remoteRuntimeVersionOperation.completionBlock = {
                let result = remoteRuntimeVersionOperation.result
                switch result {
                case let .success(version):
                    continuation.resume(returning: version)
                case let .failure(error):
                    continuation.resume(throwing: error)
                case .none:
                    continuation
                        .resume(throwing: RuntimeSyncServiceError.missingRuntimeVersionResult)
                }
            }
        }
    }

    private func clearOperations(for chainId: ChainModel.Id) {
        if let existingOperation = syncingChains[chainId] {
            syncingChains[chainId] = nil
            existingOperation.cancel()
        }

        retryAttempts[chainId] = nil
    }
}

extension RuntimeSyncService: SchedulerDelegate {
    public func didTrigger(scheduler _: SchedulerProtocol) async {
        retryScheduler = nil

        for requestKeyValue in retryAttempts where syncingChains[requestKeyValue.key] == nil {
            if requestKeyValue.value.runtimeVersion != nil {
                Task {
                    await performSync(
                        for: requestKeyValue.key
                    )
                }
            }
        }
    }
}

extension RuntimeSyncService: RuntimeSyncServiceProtocol {
    public func register(chain: ChainModel, with connection: ChainConnection) async {
        guard let knownConnection = knownChains[chain.chainId] else {
            knownChains[chain.chainId] = connection
            return
        }

        if knownConnection.connectionName != connection.connectionName {
            knownChains[chain.chainId] = connection

            performSync(for: chain.chainId)
        }
    }

    public func unregister(chainId: ChainModel.Id) async {
        clearOperations(for: chainId)
        knownChains[chainId] = nil
    }

    public func apply(version: RuntimeVersion, for chainId: ChainModel.Id) async {
        clearOperations(for: chainId)

        performSync(for: chainId, newVersion: version)
    }

    public func hasChain(with chainId: ChainModel.Id) async -> Bool {
        return knownChains[chainId] != nil
    }

    public func isChainSyncing(_ chainId: ChainModel.Id) async -> Bool {
        return (syncingChains[chainId] != nil) || (retryAttempts[chainId] != nil)
    }
}
