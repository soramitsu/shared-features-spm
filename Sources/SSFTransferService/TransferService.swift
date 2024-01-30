import Foundation
import SSFModels
import BigInt
import SSFUtils

public protocol TransferService: AnyObject {
    func submit(_ transfer: TransferType) async throws -> String
    func estimateFee(_ transfer: TransferType) async -> AsyncThrowingStream<BigUInt, Error>
}

public actor TransferServiceDefault: TransferService {
    private let wallet: MetaAccountModel
    private let secretKeyData: Data
    private let chainAsset: ChainAsset
    
    private var existSubstrateServices: [String: SubstrateTransferService] = [:]
    private var existEthereumServices: [String: EthereumTransferService] = [:]
    
    public init(
        wallet: MetaAccountModel,
        secretKeyData: Data,
        chainAsset: ChainAsset
    ) {
        self.wallet = wallet
        self.secretKeyData = secretKeyData
        self.chainAsset = chainAsset
    }

    public func submit(_ transfer: TransferType) async throws -> String {
        switch transfer {
        case .substrate(let substrateTransfer):
            let service = try await createSubstrateService()
            return try await service.submit(transfer: substrateTransfer)
        case .ethereum(let ethereumTransfer):
            let service = try createEthereumTransferService()
            return try await service.submit(transfer: ethereumTransfer)
        case .xorless(let xorlessTransfer):
            let service = try await createSubstrateService()
            return try await service.submit(transfer: xorlessTransfer)
        }
    }
    
    public func estimateFee(_ transfer: TransferType) async -> AsyncThrowingStream<BigUInt, Error> {
        do {
            switch transfer {
            case .substrate(let substrateTransfer):
                let service = try await createSubstrateService()
                return service.estimateFee(for: substrateTransfer)
            case .ethereum(let ethereumTransfer):
                let service = try createEthereumTransferService()
                return await service.estimateFee(for: ethereumTransfer)
            case .xorless(let xorlessTransfer):
                let service = try await createSubstrateService()
                return service.estimateFee(for: xorlessTransfer)
            }
        } catch {
            return Fail<BigUInt, Error>(error: error).finishedAsyncThrowingStream()
        }
    }
    
    // MARK: - Private methods
    
    private func createSubstrateService() async throws -> SubstrateTransferService {
        let key = [wallet.identifier, chainAsset.chainAssetId.id].joined(separator: ":")
        if let existService = existSubstrateServices[key] {
            return existService
        }

        let service = try await SubstrateTransferAssembly().createSubstrateService(
            wallet: wallet,
            chainAsset: chainAsset,
            secretKeyData: secretKeyData
        )
        
        existSubstrateServices[key] = service
        return service
    }
    
    private func createEthereumTransferService() throws -> EthereumTransferService {
        let key = [wallet.identifier, chainAsset.chainAssetId.id].joined(separator: ":")
        if let existService = existEthereumServices[key] {
            return existService
        }
        
        let service = try EthereumTransferServiceAssembly().createEthereumTransferService(
            wallet: wallet,
            chainAsset: chainAsset,
            secretKeyData: secretKeyData
        )
        
        existEthereumServices[key] = service
        return service
    }
}
