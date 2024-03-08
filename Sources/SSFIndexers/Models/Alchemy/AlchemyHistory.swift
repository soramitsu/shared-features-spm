import Foundation

struct AlchemyHistory: Decodable {
    let transfers: [AlchemyHistoryElement]
}

struct AlchemyHistoryElement: Decodable {
    let blockNum: String
    let uniqueId: String
    let hash: String
    let from: String
    let to: String
    let value: Decimal?
    let asset: String?
    let category: String
    let metadata: AlchemyHistoryElementMetadata?

    var timestampInSeconds: Int64 {
        guard let dateString = metadata?.blockTimestamp else {
            return 0
        }
        return AssetTransactionData.convertAlchemy(timestamp: dateString) ?? .zero
    }
}

struct AlchemyHistoryElementMetadata: Decodable {
    let blockTimestamp: String
}
