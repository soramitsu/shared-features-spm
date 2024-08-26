import Foundation
import SSFModels
import SSFUtils

public struct PoolProvidersStorageKey: Codable, Hashable {
    let reservesId: AccountId
    let accountId: AccountId

    public init(reservesId: AccountId, accountId: AccountId) {
        self.reservesId = reservesId
        self.accountId = accountId
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        reservesId = try container.decode(AccountId.self)
        accountId = try container.decode(AccountId.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(reservesId)
        try container.encode(accountId)
    }
}

extension PoolProvidersStorageKey: ScaleCodable {
    public init(scaleDecoder: ScaleDecoding) throws {
        reservesId = try AccountId(scaleDecoder: scaleDecoder)
        accountId = try AccountId(scaleDecoder: scaleDecoder)
    }

    public func encode(scaleEncoder: ScaleEncoding) throws {
        try reservesId.encode(scaleEncoder: scaleEncoder)
        try accountId.encode(scaleEncoder: scaleEncoder)
    }
}
