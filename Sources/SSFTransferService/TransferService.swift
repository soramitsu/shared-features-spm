import BigInt
import SoraKeystore
import SSFChainRegistry
import Foundation
import SSFModels
import SSFUtils

public protocol TransferService: AnyObject {
    func submit(_ transfer: TransferType, for chainAsset: ChainAsset) async throws -> String?
    func estimateFee(_ transfer: TransferType, for chainAsset: ChainAsset) async
        -> AsyncThrowingStream<BigUInt, Error>
}

public actor TransferServiceDefault: TransferService {
    private let wallet: MetaAccountModel
    private let chainRegistry: ChainRegistryProtocol
    private let keystore: KeystoreProtocol

    private var existSubstrateServices: [String: SubstrateTransferService] = [:]
    private var existEthereumServices: [String: EthereumTransferService] = [:]
    private var existTonServices: TonTransferService?

    public init(
        wallet: MetaAccountModel,
        keystore: KeystoreProtocol,
        chainRegistry: ChainRegistryProtocol
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.chainRegistry = chainRegistry
    }

    public func submit(
        _ transfer: TransferType,
        for chainAsset: ChainAsset
    ) async throws -> String? {
        switch transfer {
        case let .substrate(substrateTransfer):
            let service = try await createSubstrateService(for: chainAsset.chain)
            return try await service.submit(transfer: substrateTransfer, chainAsset: chainAsset)
        case let .ethereum(ethereumTransfer):
            let service = try await createEthereumTransferService(for: chainAsset.chain)
            return try await service.submit(transfer: ethereumTransfer, chainAsset: chainAsset)
        case let .xorless(xorlessTransfer):
            let service = try await createSubstrateService(for: chainAsset.chain)
            return try await service.submit(transfer: xorlessTransfer, chainAsset: chainAsset)
        case let .ton(tonTransfer):
            let service = try createTonTransferService(chain: chainAsset.chain)
            try await service.submit(transfer: tonTransfer)
            return nil
        }
    }

    public func estimateFee(
        _ transfer: TransferType,
        for chainAsset: ChainAsset
    ) async -> AsyncThrowingStream<BigUInt, Error> {
        do {
            switch transfer {
            case let .substrate(substrateTransfer):
                let service = try await createSubstrateService(for: chainAsset.chain)
                return service.estimateFee(for: substrateTransfer, chainAsset: chainAsset)
            case let .ethereum(ethereumTransfer):
                let service = try await createEthereumTransferService(for: chainAsset.chain)
                return await service.estimateFee(for: ethereumTransfer, chainAsset: chainAsset)
            case let .xorless(xorlessTransfer):
                let service = try await createSubstrateService(for: chainAsset.chain)
                return service.estimateFee(for: xorlessTransfer, chainAsset: chainAsset)
            case let .ton(tonTransfer):
                let service = try createTonTransferService(chain: chainAsset.chain)
                return service.estimateFee(transfer: tonTransfer)
            }
        } catch {
            return Fail<BigUInt, Error>(error: error).finishedAsyncThrowingStream()
        }
    }

    // MARK: - Private methods

    private func createSubstrateService(
        for chain: ChainModel
    ) async throws -> SubstrateTransferService {
        if let existService = existSubstrateServices[chain.chainId] {
            return existService
        }
        
        let secretKeyData = try getSecretKey(
            chain: chain,
            wallet: wallet
        )

        let service = try await SubstrateTransferAssembly().createSubstrateService(
            wallet: wallet,
            chain: chain,
            secretKeyData: secretKeyData,
            chainRegistry: chainRegistry
        )

        existSubstrateServices[chain.chainId] = service
        return service
    }

    private func createEthereumTransferService(
        for chain: ChainModel
    ) async throws -> EthereumTransferService {
        if let existService = existEthereumServices[chain.chainId] {
            return existService
        }
        
        let secretKeyData = try getSecretKey(
            chain: chain,
            wallet: wallet
        )

        let service = try await EthereumTransferServiceAssembly().createEthereumTransferService(
            wallet: wallet,
            chain: chain,
            secretKeyData: secretKeyData,
            chainRegistry: chainRegistry
        )

        existEthereumServices[chain.chainId] = service
        return service
    }
    
    private func createTonTransferService(chain: ChainModel) throws -> TonTransferService {
        if let existService = existTonServices {
            return existService
        }
        
        let secretKeyData = try getSecretKey(
            chain: chain,
            wallet: wallet
        )
        
        let service = TonTransferServiceAssembly.createService(
            chainRegistry: chainRegistry,
            secretKey: secretKeyData
        )
        existTonServices = service
        return service
    }
    
    private func getSecretKey(
        chain: ChainModel,
        wallet: MetaAccountModel
    ) throws -> Data {
        guard let accountResponse = wallet.fetch(for: chain.accountRequest()) else {
            throw TransferServiceError.accountNotExists
        }
        let accountId = accountResponse.isChainAccount ? accountResponse.accountId : nil
        let tag: String = KeystoreTagV2.secretKeyTag(
            for: chain.ecosystem,
            metaId: wallet.metaId,
            accountId: accountId
        )
        let secretKey = try keystore.fetchKey(for: tag)
        return secretKey
    }
}
