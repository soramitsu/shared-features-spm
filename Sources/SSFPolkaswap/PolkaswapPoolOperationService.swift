import Foundation
import BigInt
import SSFPools
import SSFSigner
import SSFExtrinsicKit

final class PolkaswapPoolOperationService {
    
    private let extrisicService: ExtrinsicServiceProtocol
    private let signingWrapper: TransactionSignerProtocol
    private let poolService: PoolsService
    private let extrinsicBuilder: PoolsExtrinsicBuilder
    
    init(
        extrinsicBuilder: PoolsExtrinsicBuilder,
        extrisicService: ExtrinsicServiceProtocol,
        signingWrapper: TransactionSignerProtocol,
        poolService: PoolsService
    ) {
        self.extrinsicBuilder = extrinsicBuilder
        self.extrisicService = extrisicService
        self.signingWrapper = signingWrapper
        self.poolService = poolService
    }
}

extension PolkaswapPoolOperationService: PoolsOperationService {
    func submit(liquidityOperation: PoolOperation) async throws -> String {
        switch liquidityOperation {
        case .substrateSupplyLiquidity(let model):
            return try await submitSupplyLiquidity(model: model)
        case .substrateRemoveLiquidity(let model):
            return try await submitRemoveLiquidity(model: model)
        }
    }
    
    func estimateFee(liquidityOperation: PoolOperation) async throws -> BigUInt {
        switch liquidityOperation {
        case .substrateSupplyLiquidity(let model):
            return try await estimateFeeSupplyLiquidity(model: model)
        case .substrateRemoveLiquidity(let model):
            return try await estimateFeeRemoveLiquidity(model: model)
        }
    }
    
    func submitSupplyLiquidity(model: SupplyLiquidityInfo) async throws -> String {
        let pairs = try await poolService.getAllPairs()

        let closure = try extrinsicBuilder.depositLiqudityExtrinsic(
            pairs: pairs,
            model: model
        )
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: PoolsOperationServiceError.unexpectedError)
                return
            }

            self.extrisicService.submit(
                closure,
                signer: self.signingWrapper,
                runningIn: .global(),
                completion: { result in
                    switch result {
                    case .success(let hash):
                        continuation.resume(returning: hash)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
    
    func submitRemoveLiquidity(model: RemoveLiquidityInfo) async throws -> String {
        let closure = try extrinsicBuilder.removeLiqudityExtrinsic(model: model)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: PoolsOperationServiceError.unexpectedError)
                return
            }

            self.extrisicService.submit(
                closure,
                signer: self.signingWrapper,
                runningIn: .global(),
                completion: { result in
                    switch result {
                    case .success(let hash):
                        continuation.resume(returning: hash)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
    
    func estimateFeeSupplyLiquidity(model: SupplyLiquidityInfo) async throws -> BigUInt {
        let pairs = try await poolService.getAllPairs()

        let closure = try extrinsicBuilder.depositLiqudityExtrinsic(
            pairs: pairs,
            model: model
        )
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: PoolsOperationServiceError.unexpectedError)
                return
            }

            self.extrisicService.estimateFee(
                closure,
                runningIn: .global(),
                completion: { result in
                    switch result {
                    case .success(let fee):
                        continuation.resume(returning: fee.feeValue)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
    
    func estimateFeeRemoveLiquidity(model: RemoveLiquidityInfo) async throws -> BigUInt {
        let closure = try extrinsicBuilder.removeLiqudityExtrinsic(model: model)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: PoolsOperationServiceError.unexpectedError)
                return
            }

            self.extrisicService.estimateFee(
                closure,
                runningIn: .global(),
                completion: { result in
                    switch result {
                    case .success(let fee):
                        continuation.resume(returning: fee.feeValue)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
}
