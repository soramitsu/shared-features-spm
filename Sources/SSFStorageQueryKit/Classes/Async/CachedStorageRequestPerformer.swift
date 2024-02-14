import Foundation

public struct CachedStorageRequestTrigger: OptionSet {
    public typealias RawValue = UInt8
    public private(set) var rawValue: UInt8
    
    public static var onPerform: CachedStorageRequestTrigger { CachedStorageRequestTrigger(rawValue: 0) }
    public static var cache: CachedStorageRequestTrigger { CachedStorageRequestTrigger(rawValue: 1 << 0) }
    
    public static var onAll: CachedStorageRequestTrigger {
        let rawValue = CachedStorageRequestTrigger.onPerform.rawValue |
        CachedStorageRequestTrigger.cache.rawValue

        return CachedStorageRequestTrigger(rawValue: rawValue)
    }
    
    public init(rawValue: CachedStorageRequestTrigger.RawValue) {
        self.rawValue = rawValue
    }
}
