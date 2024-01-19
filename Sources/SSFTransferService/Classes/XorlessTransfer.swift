import Foundation
import BigInt
import SSFUtils

//struct XorlessTransfer: Codable {
//    let dexId: String
//    let assetId: SoraAssetId
//    let receiver: Data
//    @StringCodable var amount: BigUInt
//    @StringCodable var desiredXorAmount: BigUInt
//    @StringCodable var maxAmountIn: BigUInt
//    let selectedSourceTypes: [[String?]]
//    let filterMode: PolkaswapCallFilterModeType
//    let additionalData: Data
//
//    enum CodingKeys: String, CodingKey {
//        case dexId
//        case assetId
//        case receiver
//        case amount
//        case desiredXorAmount = "desired_xor_amount"
//        case maxAmountIn = "max_amount_in"
//        case selectedSourceTypes = "selected_source_types"
//        case filterMode = "filter_mode"
//        case additionalData = "additional_data"
//    }
//}

struct PolkaswapCallFilterModeType: Codable {
    var name: String
    var value: UInt?

    init(wrappedName: String, wrappedValue: UInt?) {
        name = wrappedName
        value = wrappedValue
    }

    init(from decoder: Decoder) throws {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value: [String?] = [name, nil]
        try container.encode(value)
    }
}
