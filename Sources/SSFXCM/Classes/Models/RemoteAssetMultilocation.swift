import Foundation
import SSFModels

// MARK: - RemoteAssetMultilocation
struct RemoteAssetMultilocation: Codable {
    let name: String
    let chainId: String
    let assets: [AssetMultilocation]
}

// MARK: - Asset
struct AssetMultilocation: Codable {
    let id: String
    let symbol: String
    let interiors: [XcmJunction]
}
