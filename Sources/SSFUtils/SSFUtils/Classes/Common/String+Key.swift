import Foundation

extension String {
    public func assetIdFromKey() -> String {
        return "0x" + self.suffix(64)
    }
}
