import Foundation

struct TransactionHistoryMergeResult {
    let historyItems: [AssetTransactionData]
    let identifiersToRemove: [String]
}
