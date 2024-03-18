import Foundation
import SSFModels

extension AssetTransactionData {
    static func createTransaction(
        from item: AlchemyHistoryElement,
        address: String
    ) -> AssetTransactionData {
        let peerAddress = item.from == address ? item.to : item.from
        let type: TransactionType = item.from == address ? .outgoing : .incoming

        let timestamp = Self.convertAlchemy(timestamp: item.metadata?.blockTimestamp)

        return AssetTransactionData(
            transactionId: item.uniqueId,
            status: .commited,
            assetId: item.asset,
            peerId: nil,
            peerFirstName: nil,
            peerLastName: nil,
            peerName: peerAddress,
            details: nil,
            amount: SubstrateAmountDecimal(value: item.value),
            fees: [],
            timestamp: timestamp,
            type: type.rawValue,
            reason: nil,
            context: nil
        )
    }
    
    static func convertAlchemy(timestamp: String?) -> Int64? {
        guard let timestamp else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: timestamp)
        guard let dateStamp = date?.timeIntervalSince1970 else {
            return nil
        }
        return Int64(dateStamp)
    }
}
