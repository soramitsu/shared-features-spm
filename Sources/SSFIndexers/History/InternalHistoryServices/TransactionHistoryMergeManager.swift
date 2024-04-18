import Foundation
import SSFModels

final class TransactionHistoryMergeManager {
    private let address: String
    private let chainAsset: ChainAsset

    init(
        address: String,
        chainAsset: ChainAsset
    ) {
        self.address = address
        self.chainAsset = chainAsset
    }

    func merge(
        subscanItems: [WalletRemoteHistoryItemProtocol],
        localItems: [TransactionHistoryItem]
    ) -> TransactionHistoryMergeResult {
        let hashesToRemove: [String] = findHashesToRemove(
            in: localItems,
            with: subscanItems
        )

        let filterSet = Set(hashesToRemove)
        let localMergeItems: [TransactionHistoryMergeItem] = localItems.compactMap { item in
            guard !filterSet.contains(item.txHash) else {
                return nil
            }

            return TransactionHistoryMergeItem.local(item: item)
        }

        let remoteMergeItems: [TransactionHistoryMergeItem] = subscanItems.map {
            TransactionHistoryMergeItem.remote(remote: $0)
        }

        let transactionsItems = (localMergeItems + remoteMergeItems)
            .sorted { $0.compareWithItem($1) }
            .map { item in
                item.buildTransactionData(
                    address: address,
                    chainAsset: chainAsset
                )
            }

        let results = TransactionHistoryMergeResult(
            historyItems: transactionsItems,
            identifiersToRemove: hashesToRemove
        )

        return results
    }

    func merge(
        subqueryItems: [WalletRemoteHistoryItemProtocol],
        localItems: [TransactionHistoryItem]
    ) -> TransactionHistoryMergeResult {
        let hashesToRemove: [String] = findHashesToRemove(
            in: localItems,
            with: subqueryItems
        )

        let filterSet = Set(hashesToRemove)
        let localMergeItems: [TransactionHistoryMergeItem] = localItems.compactMap { item in
            guard !filterSet.contains(item.txHash) else {
                return nil
            }

            return TransactionHistoryMergeItem.local(item: item)
        }

        let remoteMergeItems: [TransactionHistoryMergeItem] = subqueryItems.map {
            TransactionHistoryMergeItem.remote(remote: $0)
        }

        let transactionsItems = (localMergeItems + remoteMergeItems)
            .sorted { $0.compareWithItem($1) }
            .map { item in
                item.buildTransactionData(
                    address: address,
                    chainAsset: chainAsset
                )
            }

        let results = TransactionHistoryMergeResult(
            historyItems: transactionsItems,
            identifiersToRemove: hashesToRemove
        )

        return results
    }
    
    // MARK: - Private methods
    
    private func findHashesToRemove(
        in localItems: [TransactionHistoryItem],
        with items: [WalletRemoteHistoryItemProtocol]
    ) -> [String] {
        let existingHashes = Set(items.map(\.identifier))
        let minSubscanItem = items.last

        let hashesToRemove: [String] = localItems.compactMap { item in
            if existingHashes.contains(item.txHash) {
                return item.txHash
            }

            guard let subscanItem = minSubscanItem else {
                return nil
            }

            if item.timestamp < subscanItem.itemTimestamp {
                return item.txHash
            }

            return nil
        }
        return hashesToRemove
    }
}
