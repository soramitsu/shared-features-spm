import Foundation
import SSFModels

protocol WalletRemoteHistoryItemProtocol {
    var identifier: String { get }
    var itemBlockNumber: UInt64 { get }
    var itemExtrinsicIndex: UInt16 { get }
    var itemTimestamp: Int64 { get }
    var label: WalletRemoteHistorySourceLabel { get }

    func createTransactionForAddress(
        _ address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData
}

enum WalletRemoteHistorySourceLabel: Int, CaseIterable {
    case transfers
    case rewards
    case extrinsics
}
