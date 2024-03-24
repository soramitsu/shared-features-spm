import Foundation

enum AssetKeyExtractionError: Error {
    case invalidSize
}

extension String {
     public func assetIdFromKey() throws -> String {
        guard self.count > 64 else {
            throw AssetKeyExtractionError.invalidSize
        }
        return "0x" + self.suffix(64)
    }
}
