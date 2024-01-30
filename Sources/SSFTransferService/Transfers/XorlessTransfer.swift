import Foundation
import BigInt
import SSFUtils

public struct XorlessTransfer: Codable {
    public let dexId: String
    public let assetId: SoraAssetId
    public let receiver: Data
    @StringCodable public var amount: BigUInt
    @StringCodable public var desiredXorAmount: BigUInt
    @StringCodable public var maxAmountIn: BigUInt
    public let selectedSourceTypes: [[String?]]
    public let filterMode: PolkaswapCallFilterModeType
    public let additionalData: Data
    
    public init(
        dexId: String,
        assetId: SoraAssetId,
        receiver: Data,
        amount: BigUInt,
        desiredXorAmount: BigUInt,
        maxAmountIn: BigUInt,
        selectedSourceTypes: [[String?]],
        filterMode: PolkaswapCallFilterModeType,
        additionalData: Data
    ) {
        self.dexId = dexId
        self.assetId = assetId
        self.receiver = receiver
        self.amount = amount
        self.desiredXorAmount = desiredXorAmount
        self.maxAmountIn = maxAmountIn
        self.selectedSourceTypes = selectedSourceTypes
        self.filterMode = filterMode
        self.additionalData = additionalData
    }

    enum CodingKeys: String, CodingKey {
        case dexId
        case assetId
        case receiver
        case amount
        case desiredXorAmount = "desired_xor_amount"
        case maxAmountIn = "max_amount_in"
        case selectedSourceTypes = "selected_source_types"
        case filterMode = "filter_mode"
        case additionalData = "additional_data"
    }
}

//TODO: - Move to polkaswap package

public struct PolkaswapCallFilterModeType: Codable {
    public var name: String
    public var value: UInt?

    public init(wrappedName: String, wrappedValue: UInt?) {
        name = wrappedName
        value = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let dict = try container.decode([String?].self)
            let val1 = dict.first ?? "-"
            let val2 = dict.last ?? nil
            name = val1 ?? "-"

            if let value = val2 {
                self.value = UInt(value)
            }
        } catch {
            let dict = try container.decode(JSON.self)
            name = dict.arrayValue?.first?.stringValue ?? "-"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value: [String?] = [name, nil]
        try container.encode(value)
    }
}

public struct SoraAssetId: Codable {
    @ArrayCodable public var value: String

    public init(wrappedValue: String) {
        value = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String: Data].self)

        value = dict["code"]?.toHex(includePrefix: true) ?? "-"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard
            let bytes = try? Data(hexStringSSF: value).map({ StringScaleMapper(value: $0) })
        else {
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid encoding"
            )
            throw EncodingError.invalidValue(value, context)
        }
        try container.encode(["code": bytes])
    }
}

@propertyWrapper
public struct ArrayCodable: Codable, Equatable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let byteArray = try container.decode([StringScaleMapper<UInt8>].self)
        let value = byteArray.reduce("0x") { $0 + String(format: "%02x", $1.value) }

        wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        guard
            let bytes = try? Data(hexStringSSF: wrappedValue).map({ StringScaleMapper(value: $0) })
        else {
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid encoding"
            )
            throw EncodingError.invalidValue(wrappedValue, context)
        }

        try container.encode(bytes)
    }
}
