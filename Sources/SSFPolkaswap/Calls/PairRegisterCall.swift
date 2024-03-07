import SSFUtils

struct PairRegisterCall: Codable {
    let dexId: String
    var baseAssetId: SoraAssetId
    var targetAssetId: SoraAssetId

    enum CodingKeys: String, CodingKey {
        case dexId = "dexId"
        case baseAssetId = "baseAssetId"
        case targetAssetId = "targetAssetId"
    }
}
