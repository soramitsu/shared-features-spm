import Foundation
import OrderedCollections
import Web3
import SSFModels
import Web3ContractABI
import SSFUtils
import BigInt

protocol EthereumTransferService {
    func submit(transfer: EthereumTransfer) async throws -> String
    func estimateFee(for transfer: EthereumTransfer) async -> AsyncThrowingStream<BigUInt, Error>
    func unsubscribeFromFee() async throws -> Bool
}

final class EthereumTransferServiceDefault: EthereumTransferService {

    private let privateKey: EthereumPrivateKey
    private let senderAddress: String
    private let chainAsset: ChainAsset
    private let callFactory: EthereumCallFactory
    private let ethereumService: EthereumService

    private var feeSubscriptionId: String?

    init(
        privateKey: EthereumPrivateKey,
        senderAddress: String,
        chainAsset: ChainAsset,
        callFactory: EthereumCallFactory,
        ethereumService: EthereumService
    ) {
        self.privateKey = privateKey
        self.senderAddress = senderAddress
        self.chainAsset = chainAsset
        self.callFactory = callFactory
        self.ethereumService = ethereumService
    }

    deinit {
        guard let subscriptionId = feeSubscriptionId else {
            return
        }
        Task {
            try? await ethereumService.unsubscribe(subscriptionId: subscriptionId)
        }
    }
    
    // MARK: - EthereumTransferService
    
    func submit(
        transfer: EthereumTransfer
    ) async throws -> String {
        switch chainAsset.asset.ethereumType {
        case .normal:
            return try await transferNative(transfer: transfer)
        case .erc20, .bep20:
            return try await transferERC20(transfer: transfer)
        case .none:
            throw TransferServiceError.transferFailed(reason: "unknown asset")
        }
    }
    
    func estimateFee(
        for transfer: EthereumTransfer
    ) async -> AsyncThrowingStream<BigUInt, Error> {
        guard ethereumService.hasSubscription else {
            return fetchBlockAndEstimateFee(for: transfer)
        }
        
        if let currentSubscription = feeSubscriptionId {
            return await replaceCurrent(currentSubscription, for: transfer)
        } else {
            return subscribeToBlocksAndEstimateFee(for: transfer)
        }
    }
    
    func unsubscribeFromFee() async throws -> Bool {
        guard let feeSubscriptionId = feeSubscriptionId else {
            throw TransferServiceError.unsubscribeFailed
        }
        return try await ethereumService.unsubscribe(subscriptionId: feeSubscriptionId)
    }
    
    // MARK: - Private transfer methods
    
    private func replaceCurrent(
        _ subscriptionId: String,
        for transfer: EthereumTransfer
    ) async -> AsyncThrowingStream<BigUInt, Error> {
        do {
            guard try await ethereumService.unsubscribe(subscriptionId: subscriptionId) else {
                throw TransferServiceError.unsubscribeFailed
            }
            return subscribeToBlocksAndEstimateFee(for: transfer)
        } catch {
            return Fail(error: error).finishedAsyncThrowingStream()
        }
    }
    
    private func transferNative(
        transfer: EthereumTransfer
    ) async throws -> String {
        let rawTransaction = try await callFactory.signNative(transfer: transfer)
        let result = try await ethereumService.send(rawTransaction)

        return result.hex()
    }
    
    private func transferERC20(
        transfer: EthereumTransfer
    ) async throws -> String {
        let rawTransaction = try await callFactory.signERC20(transfer: transfer)
        let result = try await ethereumService.send(rawTransaction)
        
        return result.hex()
    }
    
    // MARK: - Private fee subscription methods
    
    private func subscribeToBlocksAndEstimateFee(
        for transfer: EthereumTransfer
    ) -> AsyncThrowingStream<BigUInt, Error> {
        AsyncThrowingStream { continuation in
            do {
                try subscribeAndHandleEvent(with: continuation, for: transfer)
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
    
    private func subscribeAndHandleEvent(
        with continuation: AsyncThrowingStream<BigUInt, Error>.Continuation,
        for transfer: EthereumTransfer
    ) throws {
        try ethereumService.connection.subscribeToNewHeads { [weak self] subscriptionId in
            self?.feeSubscriptionId = subscriptionId.result
        } onEvent: { [weak self] responce in
            guard let self else {
                continuation.finish(throwing: TransferServiceError.weakSelf)
                return
            }

            switch responce.status {
            case let .success(blockObject):
                startTaskForEstimateFee(with: continuation, for: transfer, blockObject: blockObject)
            case let .failure(error):
                continuation.finish(throwing: error)
            }
        }
    }
    
    private func startTaskForEstimateFee(
        with continuation: AsyncThrowingStream<BigUInt, Error>.Continuation,
        for transfer: EthereumTransfer,
        blockObject: EthereumBlockObject
    ) {
        let task = Task {
            do {
                let fee = try await self.estimateFee(for: blockObject, transfer: transfer)
                continuation.yield(fee)
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in
            task.cancel()
        }
    }
    
    private func fetchBlockAndEstimateFee(
        for transfer: EthereumTransfer
    ) -> AsyncThrowingStream<BigUInt, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let blockObject = try await ethereumService.getBlockByNumber(block: .latest, fullTransactionObjects: false)
                    guard let blockObject = blockObject else {
                        throw TransferServiceError.cannotEstimateFee(reason: "block is missed")
                    }
                    let fee = try await self.estimateFee(for: blockObject, transfer: transfer)
                    continuation.yield(fee)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private func estimateFee(
        for newHead: EthereumBlockObject,
        transfer: EthereumTransfer
    ) async throws -> BigUInt {
        guard let baseFeePerGas = newHead.baseFeePerGas else {
            let error = TransferServiceError.cannotEstimateFee(reason: "unexpected new block head response")
            throw error
        }

        return try await estimateFee(for: transfer, baseFeePerGas: baseFeePerGas)
    }
    
    private func estimateFee(
        for transfer: EthereumTransfer,
        baseFeePerGas: EthereumQuantity
    ) async throws -> BigUInt {
        switch chainAsset.asset.ethereumType {
        case .normal:
            let address = try EthereumAddress(rawAddress: transfer.receiver.hexToBytes())
            let call = EthereumCall(to: address)
            
            return try await estimateNativeTokenFee(for: call, baseFeePerGas: baseFeePerGas)
        case .erc20, .bep20:
            let address = try EthereumAddress(rawAddress: transfer.receiver.hexToBytes())
            let senderAddress = try EthereumAddress(rawAddress: senderAddress.hexToBytes())
            let contractAddress = try EthereumAddress(rawAddress: chainAsset.asset.id.hexToBytes())
            let contract = ethereumService.connection.Contract(type: GenericERC20Contract.self, address: contractAddress)
            let transfer = contract.transfer(to: address, value: transfer.amount)
            
            return try await estimateContractTokenFee(
                senderAddress: senderAddress,
                transfer: transfer,
                baseFeePerGas: baseFeePerGas
            )
        case .none:
            let error = TransferServiceError.cannotEstimateFee(reason: "unknown asset")
            throw error
        }
    }
    
    private func estimateNativeTokenFee(
        for call: EthereumCall,
        baseFeePerGas: EthereumQuantity
    ) async throws -> BigUInt {
        async let maxPriorityFeePerGas = try ethereumService.queryMaxPriorityFeePerGas()
        async let gasLimit = try ethereumService.queryGasLimit(call: call)

        let fee = try await gasLimit.quantity * (baseFeePerGas.quantity + maxPriorityFeePerGas.quantity)
        return fee
    }
    
    private func estimateContractTokenFee(
        senderAddress: EthereumAddress,
        transfer: SolidityInvocation,
        baseFeePerGas: EthereumQuantity
    ) async throws -> BigUInt {
        async let maxPriorityFeePerGas = try ethereumService.queryMaxPriorityFeePerGas()
        async let transferGasLimit = try ethereumService.queryGasLimit(
            from: senderAddress,
            amount: EthereumQuantity(quantity: BigUInt.zero),
            transfer: transfer
        )
        
        let fee = try await (maxPriorityFeePerGas.quantity + baseFeePerGas.quantity) * transferGasLimit.quantity
        return fee
    }
}
