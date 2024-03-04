import Foundation
import SSFModels

extension AssetTransactionData {
    static func createTransaction(
        from item: OklinkTransactionItem,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        let peerAddress = item.from == address ? item.to : item.from
        let type = item.from == address ? TransactionType.outgoing :
            TransactionType.incoming

        let timestamp: Int64 = {
            let timestamp = Int64(item.transactionTime) ?? 0
            return timestamp / 1000
        }()

        let fee = AssetTransactionFee(
            identifier: chainAsset.asset.id,
            assetId: chainAsset.asset.id,
            amount: SubstrateAmountDecimal(string: item.txFee),
            context: nil
        )

        return AssetTransactionData(
            transactionId: item.blockHash,
            status: .commited,
            assetId: item.tokenContractAddress,
            peerId: "",
            peerFirstName: nil,
            peerLastName: nil,
            peerName: peerAddress,
            details: "",
            amount: SubstrateAmountDecimal(string: item.amount),
            fees: [fee],
            timestamp: timestamp,
            type: type.rawValue,
            reason: "",
            context: nil
        )
    }
}
