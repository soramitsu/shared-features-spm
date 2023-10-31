import Foundation
import RobinHood

public struct AssetVisibility: Codable, Equatable, Hashable, Identifiable {
    public var identifier: String {
        assetId
    }

    public let assetId: String
    public var visible: Bool
    
    public init(assetId: String, visible: Bool) {
        self.assetId = assetId
        self.visible = visible
    }
}
