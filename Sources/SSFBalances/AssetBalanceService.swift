import Combine
import Foundation
import SSFAssetManagment
import SSFModels
import SSFStorageQueryKit
import SSFUtils

public typealias ChainAssetBalanceSubscription = (
    id: AssetBalanceSubscriptionId,
    publisher: PassthroughSubject<ChainAssetBalanceInfo?, Never>
)

public typealias AssetBalanceSubscription = (
    id: AssetBalanceSubscriptionId,
    publisher: PassthroughSubject<AssetBalanceInfo?, Never>
)

public typealias AssetsBalanceSubscription = (
    ids: [AssetBalanceSubscriptionId],
    publisher: PassthroughSubject<[AssetBalanceInfo], Error>
)

enum AssetBalanceServiceError: Error {
    case notFound
}

public struct AssetBalanceSubscriptionId {
    let subscriptionId: UInt16
    let chainAsset: ChainAsset
}

public protocol AssetBalanceService {
    func getBalance(
        for chainAsset: ChainAsset,
        accountId: AccountId
    ) async throws -> AssetBalanceInfo

    func getBalances(
        for chainAssets: [ChainAsset],
        accountId: AccountId
    ) async throws -> [AssetBalanceInfo]

    func getBalances(
        for chain: ChainModel,
        accountId: AccountId
    ) async throws -> [AssetBalanceInfo]

    func getBalances(
        for chains: [ChainModel],
        accountId: AccountId
    ) async throws -> [AssetBalanceInfo]

    func subscribeBalance(
        on chainAsset: ChainAsset,
        accountId: AccountId
    ) async throws -> ChainAssetBalanceSubscription

    func subscribeBalances(
        on chainAssets: [ChainAsset],
        accountId: AccountId
    ) async throws -> AssetsBalanceSubscription

    func subscribeBalances(
        on chain: ChainModel,
        accountId: AccountId
    ) async throws -> AssetsBalanceSubscription

    func subscribeBalances(
        on chains: [ChainModel],
        accountId: AccountId
    ) async throws -> AssetsBalanceSubscription

    func unsubscribe(ids: [AssetBalanceSubscriptionId]) async throws
}

public final class AssetBalanceServiceDefault {
    let remoteService: AccountInfoRemoteService
    let localService: LocalAssetBalanceService
    let subscriptionService: BalanceSubscriptionService

    public init(
        remoteService: AccountInfoRemoteService,
        localService: LocalAssetBalanceService,
        subscriptionService: BalanceSubscriptionService
    ) {
        self.remoteService = remoteService
        self.localService = localService
        self.subscriptionService = subscriptionService
    }
}

extension AssetBalanceServiceDefault: AssetBalanceService {
    public func getBalance(
        for chainAsset: ChainAsset,
        accountId: AccountId
    ) async throws -> AssetBalanceInfo {
        guard let accountInfo = try await remoteService.fetchAccountInfo(
            for: chainAsset,
            accountId: accountId
        ) else {
            throw AssetBalanceServiceError.notFound
        }

        let balance = Decimal.fromSubstrateAmount(
            accountInfo.data.sendAvailable,
            precision: Int16(chainAsset.asset.precision)
        )

        return AssetBalanceInfo(
            chainId: chainAsset.chain.chainId,
            assetId: chainAsset.asset.tokenProperties?.currencyId ?? "",
            balance: balance,
            price: nil,
            deltaPrice: nil
        )
    }

    public func getBalances(
        for chainAssets: [ChainAsset],
        accountId: AccountId
    ) async throws -> [AssetBalanceInfo] {
        try await chainAssets.asyncMap { chainAsset in
            try await getBalance(for: chainAsset, accountId: accountId)
        }
    }

    public func getBalances(
        for chain: ChainModel,
        accountId: AccountId
    ) async throws -> [AssetBalanceInfo] {
        let balacesMap = try await remoteService.fetchAccountInfos(for: chain, accountId: accountId)

        return balacesMap.compactMap { id, accountInfo in
            guard let accountInfo = accountInfo,
                  let chainAsset = chain.chainAssets.first(where: { $0.chainAssetId == id }),
                  let assetId = chainAsset.asset.tokenProperties?.currencyId else
            {
                return nil
            }

            let balance = Decimal.fromSubstrateAmount(
                accountInfo.data.sendAvailable,
                precision: Int16(chainAsset.asset.precision)
            )

            return AssetBalanceInfo(
                chainId: chain.chainId,
                assetId: assetId,
                balance: balance,
                price: nil,
                deltaPrice: nil
            )
        }
    }

    public func getBalances(
        for chains: [ChainModel],
        accountId: AccountId
    ) async throws -> [AssetBalanceInfo] {
        let balances = try await chains.asyncCompactMap { chainAsset in
            try await getBalances(for: chainAsset, accountId: accountId)
        }
        return balances.reduce([], +)
    }

    public func subscribeBalance(
        on chainAsset: ChainAsset,
        accountId: AccountId
    ) async throws -> ChainAssetBalanceSubscription {
        let publisher = PassthroughSubject<ChainAssetBalanceInfo?, Never>()

        let updateClosure: (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void = { [weak self] _ in
            Task { [weak self] in
                guard let self else { return }

                do {
                    let balance = try await self.getBalance(for: chainAsset, accountId: accountId)
                    publisher.send(ChainAssetBalanceInfo(chainAsset: chainAsset, balanceInfo: balance))
                    try await self.localService.sync(remoteBalances: [balance])
                } catch {
                    print("OLOLOLO error \(error)")
                    let allBalances = try await self.localService.get()
                    let localBalance = allBalances
                        .first(where: { $0.chainAssetId == chainAsset.chainAssetId.id })
                    publisher.send(ChainAssetBalanceInfo(chainAsset: chainAsset, balanceInfo: localBalance))
                }
            }
        }

        let failureClosure: (Error, Bool) -> Void = { [weak self] error, _ in
            publisher.send(nil)
        }

        let subscriptionId = try await subscriptionService.createBalanceSubscription(
            accountId: accountId,
            chainAsset: chainAsset,
            updateClosure: updateClosure,
            failureClosure: failureClosure
        )

        let id = AssetBalanceSubscriptionId(subscriptionId: subscriptionId, chainAsset: chainAsset)

        return (id: id, publisher: publisher)
    }

    public func subscribeBalances(
        on chainAssets: [ChainAsset],
        accountId: AccountId
    ) async throws -> AssetsBalanceSubscription {
        let publisher = PassthroughSubject<[AssetBalanceInfo], Error>()

        let updateClosure: (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void = { [weak self] _ in
            Task { [weak self] in
                guard let self else { return }

                do {
                    let balances = try await self.getBalances(
                        for: chainAssets,
                        accountId: accountId
                    )
                    publisher.send(balances)
                    try await self.localService.sync(remoteBalances: balances)
                } catch {
                    print("OLOLOLO error \(error)")
                    let allBalances = try await self.localService.get()
                    let ids = chainAssets.map { $0.chainAssetId.id }
                    let localBalances = allBalances.filter { ids.contains($0.chainAssetId) }
                    publisher.send(localBalances)
                }
            }
        }

        let failureClosure: (Error, Bool) -> Void = { [weak self] error, _ in
            guard let self else { return }
            publisher.send(completion: .failure(error))
        }

        let ids = try await chainAssets.asyncCompactMap { chainAsset in
            let subscriptionId = try await subscriptionService.createBalanceSubscription(
                accountId: accountId,
                chainAsset: chainAsset,
                updateClosure: updateClosure,
                failureClosure: failureClosure
            )

            return AssetBalanceSubscriptionId(
                subscriptionId: subscriptionId,
                chainAsset: chainAsset
            )
        }

        return (ids: ids, publisher: publisher)
    }

    public func subscribeBalances(
        on chain: ChainModel,
        accountId: AccountId
    ) async throws -> AssetsBalanceSubscription {
        let publisher = PassthroughSubject<[AssetBalanceInfo], Error>()

        let updateClosure: (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void = { [weak self] _ in
            Task { [weak self] in
                guard let self else { return }
                do {
                    let remoteBalances = try await self.getBalances(
                        for: chain,
                        accountId: accountId
                    )
                    publisher.send(remoteBalances)
                    try await self.localService.sync(remoteBalances: remoteBalances)
                } catch {
                    print("OLOLOLO error \(error)")
                    let allBalances = try await self.localService.get()
                    let ids = chain.chainAssets.map { $0.chainAssetId.id }
                    let localBalances = allBalances.filter { ids.contains($0.chainAssetId) }
                    publisher.send(localBalances)
                }
            }
        }

        let failureClosure: (Error, Bool) -> Void = { [weak self] error, _ in
            guard let self else { return }
            publisher.send(completion: .failure(error))
        }

        let ids = try await chain.chainAssets.asyncCompactMap { chainAsset in
            let subscriptionId = try await subscriptionService.createBalanceSubscription(
                accountId: accountId,
                chainAsset: chainAsset,
                updateClosure: updateClosure,
                failureClosure: failureClosure
            )

            return AssetBalanceSubscriptionId(
                subscriptionId: subscriptionId,
                chainAsset: chainAsset
            )
        }

        return (ids: ids, publisher: publisher)
    }

    public func subscribeBalances(
        on chains: [ChainModel],
        accountId: AccountId
    ) async throws -> AssetsBalanceSubscription {
        let publisher = PassthroughSubject<[AssetBalanceInfo], Error>()

        let updateClosure: (JSONRPCSubscriptionUpdate<StorageUpdate>) -> Void = { [weak self] _ in
            Task { [weak self] in
                guard let self else { return }

                do {
                    let balances = try await self.getBalances(for: chains, accountId: accountId)
                    publisher.send(balances)
                    try await self.localService.sync(remoteBalances: balances)
                } catch {
                    print("OLOLOLO error \(error)")
                    let allBalances = try await self.localService.get()
                    let ids = chains.map { $0.chainAssets }.reduce([], +).map { $0.chainAssetId.id }
                    let localBalances = allBalances.filter { ids.contains($0.chainAssetId) }
                    publisher.send(localBalances)
                }
            }
        }

        let failureClosure: (Error, Bool) -> Void = { [weak self] error, _ in
            guard let self else { return }
            publisher.send(completion: .failure(error))
        }

        let assets = chains.map { $0.chainAssets }.reduce([], +)
        let ids = try await assets.asyncCompactMap { chainAsset in
            let subscriptionId = try await subscriptionService.createBalanceSubscription(
                accountId: accountId,
                chainAsset: chainAsset,
                updateClosure: updateClosure,
                failureClosure: failureClosure
            )

            return AssetBalanceSubscriptionId(
                subscriptionId: subscriptionId,
                chainAsset: chainAsset
            )
        }

        return (ids: ids, publisher: publisher)
    }

    public func unsubscribe(ids: [AssetBalanceSubscriptionId]) async throws {
        try await ids.asyncForEach { id in
            try await subscriptionService.unsubscribe(
                id: id.subscriptionId,
                chainAsset: id.chainAsset
            )
        }
    }
}
