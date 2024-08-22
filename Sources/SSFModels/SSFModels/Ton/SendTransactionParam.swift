import Foundation
import TonSwift

public struct SendTransactionParam: Codable {
    public let messages: [Message]
    public let validUntil: TimeInterval
    public let from: TonSwift.Address?

    enum CodingKeys: String, CodingKey {
        case messages
        case validUntil = "valid_until"
        case from
        case source
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try container.decode([Message].self, forKey: .messages)
        validUntil = try container.decode(TimeInterval.self, forKey: .validUntil)

        if let fromValue = try? container.decode(String.self, forKey: .from) {
            from = try TonSwift.Address.parse(fromValue)
        } else {
            from = try TonSwift.Address.parse(try container.decode(String.self, forKey: .source))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(messages, forKey: .messages)
        try container.encode(validUntil, forKey: .validUntil)
        try container.encode(from, forKey: .from)
    }

    public struct Message: Codable {
        public let address: TonSwift.Address
        public let amount: Int64
        public let stateInit: String?
        public let payload: String?

        enum CodingKeys: String, CodingKey {
            case address
            case amount
            case stateInit
            case payload
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            address = try TonSwift.Address.parse(try container.decode(String.self, forKey: .address))
            amount = Int64(try container.decode(String.self, forKey: .amount)) ?? 0
            stateInit = try container.decodeIfPresent(String.self, forKey: .stateInit)
            payload = try container.decodeIfPresent(String.self, forKey: .payload)
        }
    }
}
