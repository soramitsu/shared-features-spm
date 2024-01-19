import Foundation
//import SSFUtils
import BigInt

//struct SoraAssetId: Codable {
//    @ArrayCodable var value: String
//
//    init(wrappedValue: String) {
//        value = wrappedValue
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let dict = try container.decode([String: Data].self)
//
//        value = dict["code"]?.toHex(includePrefix: true) ?? "-"
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        guard
//            let bytes = try? Data(hexStringSSF: value).map({ StringCodable(wrappedValue: $0) })
//        else {
//            let context = EncodingError.Context(
//                codingPath: container.codingPath,
//                debugDescription: "Invalid encoding"
//            )
//            throw EncodingError.invalidValue(value, context)
//        }
//        try container.encode(["code": bytes])
//    }
//}
//
//@propertyWrapper
//struct ArrayCodable: Codable, Equatable {
//    var wrappedValue: String
//
//    init(wrappedValue: String) {
//        self.wrappedValue = wrappedValue
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let byteArray = try container.decode([StringScaleMapper<UInt8>].self)
//        let value = byteArray.reduce("0x") { $0 + String(format: "%02x", $1.value) }
//
//        wrappedValue = value
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//
//        guard
//            let bytes = try? Data(hexStringSSF: wrappedValue).map({ StringScaleMapper(value: $0) })
//        else {
//            let context = EncodingError.Context(
//                codingPath: container.codingPath,
//                debugDescription: "Invalid encoding"
//            )
//            throw EncodingError.invalidValue(wrappedValue, context)
//        }
//
//        try container.encode(bytes)
//    }
//}
