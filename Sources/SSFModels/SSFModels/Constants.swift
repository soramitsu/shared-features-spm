import Foundation

public struct EthereumConstants {
    public static let accountIdLength = 20
}

public struct SubstrateConstants {
    public static let accountIdLength = 32
    public static let paraIdLength = 4
    public static let paraIdType = "polkadot_parachain::primitives::Id"
    public static let maxUnbondingRequests = 32
    public static let isNativeParachainRange: ClosedRange = 1000...1999
    public static let isNoNativeParachainRange: PartialRangeFrom = 2000...
}

public struct NetworkConstants {
    public static let websocketReconnectAttemptsLimit: Int = 2
}
