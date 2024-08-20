import Foundation
import SSFModels
import SSFUtils

public struct LiquidityPoolProperties: Codable, Hashable {
    let reservesId: AccountId
    let feeId: AccountId

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        reservesId = try container.decode(AccountId.self)
        feeId = try container.decode(AccountId.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(reservesId)
        try container.encode(feeId)
    }
}

extension LiquidityPoolProperties: ScaleCodable {
    public init(scaleDecoder: ScaleDecoding) throws {
        reservesId = try AccountId(scaleDecoder: scaleDecoder)
        feeId = try AccountId(scaleDecoder: scaleDecoder)
    }

    public func encode(scaleEncoder: ScaleEncoding) throws {
        try reservesId.encode(scaleEncoder: scaleEncoder)
        try feeId.encode(scaleEncoder: scaleEncoder)
    }
}
