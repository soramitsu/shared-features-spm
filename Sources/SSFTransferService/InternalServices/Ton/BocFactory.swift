import Foundation
import SSFModels
import TonSwift

protocol BocFactory {
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
}

final class BocFactoryImpl: BocFactory {
    private let secretKey: Data
    init(secretKey: Data) {
        self.secretKey = secretKey
    }
    
    func createTonTransactionBoc(
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
    
    func createJettonTransactionBoc(
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
    
    // MARK: - Private methods
    
    private func signTransfer(_ transfer: WalletTransfer) async throws -> Data {
        let signer = WalletTransferSecretKeySigner(secretKey: secretKey)
        return try transfer.signMessage(signer: signer)
    }
}
