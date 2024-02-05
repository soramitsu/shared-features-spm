import Foundation
import SSFUtils
import BigInt

public enum SoraAmountDecimalError: Error {
    case invalidStringValue
}

public struct SoraAmountDecimal: Codable, Equatable {
    public let decimalValue: Decimal

    public var stringValue: String {
        return (decimalValue as NSNumber).stringValue
    }

    public init(value: Decimal) {
        decimalValue = value
    }

    public init?(string: String) {
        guard let value = Decimal(string: string) else {
            return nil
        }

        self.init(value: value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let stringValue = try container.decode(String.self)

        guard let value = BigUInt(stringValue), let decimalValue = Decimal.fromSubstrateAmount(value, precision: 18) else {
            throw SoraAmountDecimalError.invalidStringValue
        }
        self.decimalValue = decimalValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}
