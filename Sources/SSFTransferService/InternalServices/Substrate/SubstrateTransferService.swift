import Foundation
import SSFModels
import SSFExtrinsicKit
import SSFSigner
import SSFUtils
import BigInt
import SSFCrypto

protocol SubstrateTransferService {
    func submit(transfer: SubstrateTransfer) async throws -> String
    func submit(transfer: XorlessTransfer) async throws -> String
    
    func estimateFee(for transfer: SubstrateTransfer) -> AsyncThrowingStream<BigUInt, Error>
    func estimateFee(for transfer: XorlessTransfer) -> AsyncThrowingStream<BigUInt, Error>
}

final class SubstrateTransferServiceDefault: SubstrateTransferService {
    private let extrinsicService: ExtrinsicServiceProtocol
    private let callFactory: SubstrateCallFactory
    private let signer: TransactionSignerProtocol
    private let chainAsset: ChainAsset
    
    init(
        extrinsicService: ExtrinsicServiceProtocol,
        callFactory: SubstrateCallFactory,
        signer: TransactionSignerProtocol,
        chainAsset: ChainAsset
    ) {
        self.extrinsicService = extrinsicService
        self.callFactory = callFactory
        self.signer = signer
        self.chainAsset = chainAsset
    }
    
    // MARK: - SubstrateTransferService
    
    func submit(
        transfer: SubstrateTransfer
    ) async throws -> String {
        let accountId = try AddressFactory.accountId(from: transfer.receiver, chain: chainAsset.chain)
        let call = callFactory.transfer(
            to: accountId,
            amount: transfer.amount,
            chainAsset: chainAsset
        )
        
        let extrinsicBuilderClosure: ExtrinsicBuilderClosure = { builder in
            var resultBuilder = builder
            resultBuilder = try builder.adding(call: call)
            
            if let tip = transfer.tip {
                resultBuilder = resultBuilder.with(tip: tip)
            }
            return resultBuilder
        }
        
        return try await submit(extrinsicBuilderClosure)
    }
    
    func submit(
        transfer: XorlessTransfer
    ) async throws -> String {
        let call = callFactory.xorlessTransfer(transfer)
        
        let extrinsicBuilderClosure: ExtrinsicBuilderClosure = { builder in
            var resultBuilder = builder
            resultBuilder = try builder.adding(call: call)
            return resultBuilder
        }
        
        return try await submit(extrinsicBuilderClosure)
    }
    
    func estimateFee(
        for transfer: SubstrateTransfer
    ) -> AsyncThrowingStream<BigUInt, Error> {
        func accountId(from address: String?, chain: ChainModel) -> AccountId {
            guard let address = address,
                  let accountId = try? AddressFactory.accountId(from: address, chain: chain)
            else {
                return AddressFactory.randomAccountId(for: chain.chainFormat)
            }
            
            return accountId
        }
        
        let accountId = accountId(from: transfer.receiver, chain: chainAsset.chain)
        let call = callFactory.transfer(
            to: accountId,
            amount: transfer.amount,
            chainAsset: chainAsset
        )
        
        let extrinsicBuilderClosure: ExtrinsicBuilderClosure = { builder in
            var resultBuilder = builder
            resultBuilder = try builder.adding(call: call)
            
            if let tip = transfer.tip {
                resultBuilder = resultBuilder.with(tip: tip)
            }
            return resultBuilder
        }
        
        return estimateFee(for: extrinsicBuilderClosure)
    }
    
    func estimateFee(
        for transfer: XorlessTransfer
    ) -> AsyncThrowingStream<BigUInt, Error> {
        let call = callFactory.xorlessTransfer(transfer)
        
        let extrinsicBuilderClosure: ExtrinsicBuilderClosure = { builder in
            var resultBuilder = builder
            resultBuilder = try builder.adding(call: call)
            return resultBuilder
        }
        
        return estimateFee(for: extrinsicBuilderClosure)
    }
    
    // MARK: - Private methods
    
    private func submit(
        _ extrinsicBuilderClosure: @escaping ExtrinsicBuilderClosure
    ) async throws -> String {
        try await withUnsafeThrowingContinuation({ continuation in
            extrinsicService.submit(
                extrinsicBuilderClosure,
                signer: self.signer,
                runningIn: .global()
            ) { result in
                switch result {
                case let .success(hash):
                    continuation.resume(returning: hash)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    private func estimateFee(
        for extrinsicBuilderClosure: @escaping ExtrinsicBuilderClosure
    ) -> AsyncThrowingStream<BigUInt, Error> {
        AsyncThrowingStream { continuation in
            extrinsicService.estimateFee(
                extrinsicBuilderClosure,
                runningIn: .global()
            ) { result in
                switch result {
                case let .success(fee):
                    continuation.yield(fee.feeValue)
                    continuation.finish()
                case let .failure(error):
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
