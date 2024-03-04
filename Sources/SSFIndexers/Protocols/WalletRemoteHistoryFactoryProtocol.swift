import Foundation

protocol WalletRemoteHistoryFactoryProtocol {
    func createOperationWrapper(
        for context: TransactionHistoryContext,
        address: String,
        count: Int
    ) async -> WalletRemoteHistoryData
}

struct WalletRemoteHistoryData {
    let historyItems: [WalletRemoteHistoryItemProtocol]
    let context: TransactionHistoryContext
}
