import Foundation

enum AlchemyHistoryBlockFilter: Encodable {
    case hex(value: String)
    case int(value: UInt64)
    case latest
    case indexed

    var value: String {
        switch self {
        case let .hex(value):
            return value
        case let .int(value):
            return "\(value)"
        case .latest:
            return "latest"
        case .indexed:
            return "indexed"
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .hex(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case .latest:
            try container.encode(value)
        case .indexed:
            try container.encode(value)
        }
    }
}
