import Foundation

import BigInt
import Foundation
import SSFExtrinsicKit
import SSFPools
import SSFSigner

public final class PolkaswapLiquidityPoolOperationService {
    private let extrisicService: ExtrinsicServiceProtocol
    private let signingWrapper: TransactionSignerProtocol
    private let poolService: PolkaswapLiquidityPoolService
    private let extrinsicBuilder: PoolsExtrinsicBuilder

    init(
        extrinsicBuilder: PoolsExtrinsicBuilder,
        extrisicService: ExtrinsicServiceProtocol,
        signingWrapper: TransactionSignerProtocol,
        poolService: PolkaswapLiquidityPoolService
    ) {
        self.extrinsicBuilder = extrinsicBuilder
        self.extrisicService = extrisicService
        self.signingWrapper = signingWrapper
        self.poolService = poolService
    }
}

extension PolkaswapLiquidityPoolOperationService: PoolsOperationService {
    public func submit(liquidityOperation: PoolOperation) async throws -> String {
        switch liquidityOperation {
        case let .substrateSupplyLiquidity(model):
            return try await submitSupplyLiquidity(model: model)
        case let .substrateRemoveLiquidity(model):
            return try await submitRemoveLiquidity(model: model)
        }
    }

    public func estimateFee(liquidityOperation: PoolOperation) async throws -> BigUInt {
        switch liquidityOperation {
        case let .substrateSupplyLiquidity(model):
            return try await estimateFeeSupplyLiquidity(model: model)
        case let .substrateRemoveLiquidity(model):
            return try await estimateFeeRemoveLiquidity(model: model)
        }
    }

    func submitSupplyLiquidity(model: SupplyLiquidityInfo) async throws -> String {
        var pairs: [LiquidityPair]

        if let availablePairs = model.availablePairs {
            pairs = availablePairs
        } else {
            pairs = try await poolService.fetchAvailablePools()
        }

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
                    case let .success(hash):
                        continuation.resume(returning: hash)
                    case let .failure(error):
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
                    case let .success(hash):
                        continuation.resume(returning: hash)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }

    func estimateFeeSupplyLiquidity(model: SupplyLiquidityInfo) async throws -> BigUInt {
        var pairs: [LiquidityPair]

        if let availablePairs = model.availablePairs {
            pairs = availablePairs
        } else {
            pairs = try await poolService.fetchAvailablePools()
        }

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
                    case let .success(fee):
                        continuation.resume(returning: fee.feeValue)
                    case let .failure(error):
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
                    case let .success(fee):
                        continuation.resume(returning: fee.feeValue)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
}
