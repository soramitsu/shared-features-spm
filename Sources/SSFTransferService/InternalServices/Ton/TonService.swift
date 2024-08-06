import Foundation
import SSFChainRegistry
import TonAPI
import TonSwift

protocol TonSendService {
    func loadSeqno(address: String) async throws -> UInt64
    func loadTransactionInfo(boc: String) async throws -> Components.Schemas.MessageConsequences
    func sendTransaction(boc: String) async throws
    func getTimeoutSafely(TTL: UInt64) async -> UInt64
    
}

final class TonSendServiceDefault: TonSendService {
    private let chainRegistry: ChainRegistryProtocol
    
    init(
        chainRegistry: ChainRegistryProtocol
    ) {
        self.chainRegistry = chainRegistry
    }
    
    func loadSeqno(address: String) async throws -> UInt64 {
        let tonAPIClient = try chainRegistry.getTonApiAssembly().tonAPIClient()
        let response = try await tonAPIClient.getAccountSeqno(
            path: .init(account_id: address)
        )
        let seqno = try response.ok.body.json.seqno
        return UInt64(seqno)
    }
    
    func loadTransactionInfo(boc: String) async throws -> Components.Schemas.MessageConsequences {
        let tonAPIClient = try chainRegistry.getTonApiAssembly().tonAPIClient()
        let response = try await tonAPIClient.emulateMessageToWallet(body: .json(.init(boc: boc)))
        let info = try response.ok.body.json
        return info
    }
    
    func sendTransaction(boc: String) async throws {
        let tonAPIClient = try chainRegistry.getTonApiAssembly().tonAPIClient()
        let response = try await tonAPIClient.sendBlockchainMessage(body: .json(.init(boc: boc)))
        _ = try response.ok
    }
    
    func getTimeoutSafely(TTL: UInt64) async -> UInt64 {
        do {
            let tonAPIClient = try chainRegistry.getTonApiAssembly().tonAPIClient()
            let response = try await tonAPIClient.getRawTime(Operations.getRawTime.Input())
            let entity = try response.ok.body.json
            let time = TimeInterval(entity.time)
            return UInt64(time) + TTL
        } catch {
            return UInt64(Date().timeIntervalSince1970) + TTL
        }
    }
}

extension TonSendService {
    func getTimeoutSafely(TTL: UInt64 = 5 * 60) async -> UInt64 {
        return await getTimeoutSafely(TTL: TTL)
    }
}
