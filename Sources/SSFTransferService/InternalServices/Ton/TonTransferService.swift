import Foundation
import SSFModels
import BigInt

protocol TonTransferService {
    func submit(
        transfer: TonTransfer
    ) async throws

    func estimateFee(
        transfer: TonTransfer
    ) -> AsyncThrowingStream<BigUInt, Error>
}

final class TonTransferServiceImpl: TonTransferService {
    private let service: TonSendService
    private let bocFactory: BocFactory
    
    init(
        service: TonSendService,
        bocFactory: BocFactory
    ) {
        self.service = service
        self.bocFactory = bocFactory
    }
    
    func submit(
        transfer: TonTransfer
    ) async throws {
        let boc = try await createTransactionBoc(transfer: transfer)
        try await service.sendTransaction(boc: boc)
    }
    
    func estimateFee(
        transfer: TonTransfer
    ) -> AsyncThrowingStream<BigUInt, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let boc = try await createTransactionBoc(transfer: transfer)
                    let info = try await service.loadTransactionInfo(boc: boc)
                    let totalFee = String(info.trace.transaction.total_fees)
                    guard let fee = BigUInt(string: totalFee) else {
                        let error = TransferServiceError.cannotEstimateFee(reason: "BigUInt init error")
                        throw error
                    }
                    continuation.yield(fee)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func createTransactionBoc(
        transfer: TonTransfer
    ) async throws -> String {
        async let seqno = service.loadSeqno(address: transfer.sender.toRaw())
        async let timeout = service.getTimeoutSafely(TTL: 5 * 60)

        switch transfer.token {
        case .ton:
            let boc = try await bocFactory.createTonTransactionBoc(
                transfer: transfer,
                seqno: seqno,
                timeout: timeout
            )
            return boc
        case let .jetton(jettonWalletAddress):
            let boc = try await bocFactory.createJettonTransactionBoc(
                transfer: transfer,
                jettonWalletAddress: jettonWalletAddress,
                seqno: seqno,
                timeout: timeout
            )
            return boc
        }
    }
}
