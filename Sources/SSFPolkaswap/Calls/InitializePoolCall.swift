import SSFUtils

struct InitializePoolCall: Codable {
    let dexId: String
    var assetA: SoraAssetId
    var assetB: SoraAssetId

    enum CodingKeys: String, CodingKey {
        case dexId = "dexId"
        case assetA = "assetA"
        case assetB = "assetB"
    }
}
