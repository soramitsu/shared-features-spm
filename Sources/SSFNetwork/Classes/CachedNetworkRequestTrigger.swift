public struct CachedNetworkRequestTrigger: OptionSet {
    public typealias RawValue = UInt8
    public private(set) var rawValue: UInt8

    public static var onPerform: CachedNetworkRequestTrigger {
        CachedNetworkRequestTrigger(rawValue: 1 << 0)
    }

    public static var onCache: CachedNetworkRequestTrigger {
        CachedNetworkRequestTrigger(rawValue: 1 << 1)
    }

    public static var onAll: CachedNetworkRequestTrigger = [.onCache, onPerform]

    public init(rawValue: CachedNetworkRequestTrigger.RawValue) {
        self.rawValue = rawValue
    }
}
