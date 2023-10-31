/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

public extension CompoundOperationWrapper {
    static func createWithError(_ error: Error) -> CompoundOperationWrapper<ResultType> {
        let operation = BaseOperation<ResultType>()
        operation.result = .failure(error)
        return CompoundOperationWrapper(targetOperation: operation)
    }

    static func createWithResult(_ result: ResultType) -> CompoundOperationWrapper<ResultType> {
        let operation = BaseOperation<ResultType>()
        operation.result = .success(result)
        return CompoundOperationWrapper(targetOperation: operation)
    }
    
    func addDependency(operations: [Operation]) {
        allOperations.forEach { nextOperation in
            operations.forEach { prevOperation in
                nextOperation.addDependency(prevOperation)
            }
        }
    }

    func addDependency<T>(wrapper: CompoundOperationWrapper<T>) {
        addDependency(operations: wrapper.allOperations)
    }
}
