import CoreData
import Foundation
import RobinHood

extension CDTransactionHistoryItem: CoreDataCodable {
    public func populate(from decoder: Decoder, using _: NSManagedObjectContext) throws {
        let container = try decoder.container(keyedBy: TransactionHistoryItem.CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .txHash)
        sender = try container.decode(String.self, forKey: .sender)
        receiver = try container.decodeIfPresent(String.self, forKey: .receiver)
        status = try container.decode(Int16.self, forKey: .status)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        fee = try container.decode(String.self, forKey: .fee)
        callName = try container.decode(String.self, forKey: .callName)
        moduleName = try container.decode(String.self, forKey: .moduleName)

        if let number = try container.decodeIfPresent(UInt64.self, forKey: .blockNumber) {
            blockNumber = NSNumber(value: number)
        } else {
            blockNumber = nil
        }

        if let index = try container.decodeIfPresent(Int16.self, forKey: .txIndex) {
            txIndex = NSNumber(value: index)
        } else {
            txIndex = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TransactionHistoryItem.CodingKeys.self)

        try container.encodeIfPresent(identifier, forKey: .txHash)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(receiver, forKey: .receiver)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(fee, forKey: .fee)
        try container.encodeIfPresent(blockNumber?.uint64Value, forKey: .blockNumber)
        try container.encodeIfPresent(txIndex?.int16Value, forKey: .txIndex)
        try container.encodeIfPresent(callName, forKey: .callName)
        try container.encodeIfPresent(moduleName, forKey: .moduleName)
    }
}
