import Foundation

enum AlchemyConstants {
    static let firstBlockHex = "0x0"
}

struct AlchemyHistoryRequest: Encodable {
    let fromBlock: AlchemyHistoryBlockFilter?
    let toBlock: AlchemyHistoryBlockFilter?
    let category: [AlchemyTokenCategory]
    let withMetadata: Bool?
    let excludeZeroValue: Bool?
    let maxCount: String?
    let fromAddress: String?
    let toAddress: String?
    let order: AlchemySortOrder?

    init(fromAddress: String, category: [AlchemyTokenCategory]) {
        self.init(category: category, fromAddress: fromAddress, toAddress: nil)
    }

    init(toAddress: String, category: [AlchemyTokenCategory]) {
        self.init(category: category, fromAddress: nil, toAddress: toAddress)
    }

    init(
        fromBlock: AlchemyHistoryBlockFilter? = .hex(value: AlchemyConstants.firstBlockHex),
        toBlock: AlchemyHistoryBlockFilter? = .latest,
        category: [AlchemyTokenCategory],
        withMetadata: Bool = true,
        excludeZeroValue: Bool = true,
        maxCount: String? = nil,
        fromAddress: String?,
        toAddress: String?,
        order: AlchemySortOrder = .desc
    ) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.category = category
        self.withMetadata = withMetadata
        self.excludeZeroValue = excludeZeroValue
        self.maxCount = maxCount
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.order = order
    }
}
