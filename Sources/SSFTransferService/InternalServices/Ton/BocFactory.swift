import Foundation
import SSFModels
import TonSwift
import BigInt

public protocol BocFactory {
    func createTonTransactionBoc(
        transfer: TonTransfer,
        seqno: UInt64,
        timeout: UInt64
    ) async throws -> String
    
    func createJettonTransactionBoc(
        transfer: TonTransfer,
        jettonWalletAddress: Address,
        seqno: UInt64,
        timeout: UInt64
    ) async throws -> String
    
    func createTonConnectTransferBoc(
        sender: TonSwift.Address,
        contract: WalletContract,
        parameter: SendTransactionParam,
        seqno: UInt64,
        timeout: UInt64
    ) async throws -> String
}

public final class BocFactoryImpl: BocFactory {
    private let secretKey: Data
    public init(secretKey: Data) {
        self.secretKey = secretKey
    }
    
    public func createTonTransactionBoc(
        transfer: TonTransfer,
        seqno: UInt64,
        timeout: UInt64
    ) async throws -> String {
        try await TonTransferMessageBuilder.sendTonTransfer(
            contract: transfer.contract,
            sender: transfer.sender,
            seqno: seqno,
            value: transfer.amount,
            isMax: transfer.isMax,
            recipientAddress: transfer.recipientAddress.address,
            isBounceable: transfer.recipientAddress.isBouncable,
            comment: transfer.comment,
            timeout: timeout,
            signClosure: { transfer in
                return try await signTransfer(transfer)
            }
        )
    }
    
    public func createJettonTransactionBoc(
        transfer: TonTransfer,
        jettonWalletAddress: Address,
        seqno: UInt64,
        timeout: UInt64
    ) async throws -> String {
        try await TokenTransferMessageBuilder.sendTokenTransfer(
            contract: transfer.contract,
            sender: transfer.sender,
            seqno: seqno,
            jettonWalletAddress: jettonWalletAddress,
            value: transfer.amount,
            recipientAddress: transfer.recipientAddress.address,
            isBounceable: transfer.recipientAddress.isBouncable,
            comment: transfer.comment,
            timeout: timeout,
            signClosure: { transfer in
                return try await signTransfer(transfer)
            }
        )
    }
    
    public func createTonConnectTransferBoc(
        sender: TonSwift.Address,
        contract: WalletContract,
        parameter: SendTransactionParam,
        seqno: UInt64,
        timeout: UInt64
    ) async throws -> String {
        let payloads = parameter.messages.map { message in
            TonConnectTransferMessageBuilder.Payload(
                value: BigInt(integerLiteral: message.amount),
                recipientAddress: message.address,
                stateInit: message.stateInit,
                payload: message.payload
            )
        }
        return try await TonConnectTransferMessageBuilder.sendTonConnectTransfer(
            contract: contract,
            sender: sender,
            seqno: seqno,
            payloads: payloads,
            timeout: timeout,
            signClosure: { transfer in
                return try await signTransfer(transfer)
            }
        )
    }
    
    // MARK: - Private methods
    
    private func signTransfer(_ transfer: WalletTransfer) async throws -> Data {
        let signer = WalletTransferSecretKeySigner(secretKey: secretKey)
        return try transfer.signMessage(signer: signer)
    }
}
