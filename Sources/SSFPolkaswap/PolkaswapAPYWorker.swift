import RobinHood
import SSFUtils
import sorawallet

protocol PolkaswapAPYWorker {
    func getAPYInfo() async throws -> [SbApyInfo]
}

final class PolkaswapAPYWorkerImpl: PolkaswapAPYWorker {
    let commonConfigUrlString: String
    let mobileConfigUrlString: String
    let operationManager: OperationManagerProtocol
    
    init(
        commonConfigUrlString: String,
        mobileConfigUrlString: String,
        operationManager: OperationManagerProtocol = OperationManager()
    ) {
        self.commonConfigUrlString = commonConfigUrlString
        self.mobileConfigUrlString = mobileConfigUrlString
        self.operationManager = operationManager
    }
    
    func getAPYInfo() async throws -> [SbApyInfo] {
        let queryOperation = SubqueryApyInfoOperation<[SbApyInfo]>(
            commonConfigUrlString: commonConfigUrlString,
            mobileConfigUrlString: mobileConfigUrlString
        )
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
}
