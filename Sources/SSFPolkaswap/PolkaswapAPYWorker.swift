import RobinHood
import SSFUtils
import sorawallet

enum PolkaswapAPYWorkerError: Swift.Error {
    case unexpectedError
}

public protocol PolkaswapAPYWorker {
    func getAPYInfo() async throws -> [SbApyInfo]
}

public final class PolkaswapAPYWorkerDefault: PolkaswapAPYWorker {
    private let operationManager: OperationManagerProtocol
    private let commonUrl: String
    private let mobileUrl: String
    private var subQueryClient: SoraWalletBlockExplorerInfo?
    
    init(
        commonUrl: String,
        mobileUrl: String,
        operationManager: OperationManagerProtocol = OperationManager()
    ) {
        self.commonUrl = commonUrl
        self.mobileUrl = mobileUrl
        self.operationManager = operationManager
    }
    
    public func getAPYInfo() async throws -> [SbApyInfo] {
        let queryOperation = apyOperation()
        operationManager.enqueue(operations: [queryOperation], in: .transient)
        
        return try await withCheckedThrowingContinuation { continuation in
            queryOperation.completionBlock = {
                do {
                    let response = try queryOperation.extractNoCancellableResultData()
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func apyOperation() -> AwaitOperation<[SbApyInfo]> {
        return AwaitOperation {
            try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let self else {
                    continuation.resume(throwing: PolkaswapAPYWorkerError.unexpectedError)
                    return
                }

                let httpProvider = SoramitsuHttpClientProviderImpl()
                
                let soraNetworkClient = SoramitsuNetworkClient(
                    timeout: 60000,
                    logging: true,
                    provider: httpProvider
                )

                let provider = SoraRemoteConfigProvider(
                    client: soraNetworkClient,
                    commonUrl: self.commonUrl,
                    mobileUrl: self.mobileUrl
                )

                let configBuilder = provider.provide()

                self.subQueryClient = SoraWalletBlockExplorerInfo(
                    networkClient: soraNetworkClient,
                    soraRemoteConfigBuilder: configBuilder
                )
                
                DispatchQueue.main.async {
                    self.subQueryClient?.getSpApy(completionHandler: { requestResult, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        if let data = requestResult {
                            continuation.resume(returning: data)
                            return
                        }
                        
                        continuation.resume(throwing: PolkaswapAPYWorkerError.unexpectedError)
                    })
                }

            }
        }
    }
}
