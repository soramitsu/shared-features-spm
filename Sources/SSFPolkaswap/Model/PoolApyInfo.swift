import Foundation

public struct PoolApyInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case poolId = "id"
        case strategicBonusApy
    }

    public let poolId: String
    public let strategicBonusApy: String?

    public var apy: Decimal? {
        guard let strategicBonusApy else {
            return nil
        }

        return Decimal(string: strategicBonusApy)
    }
}
