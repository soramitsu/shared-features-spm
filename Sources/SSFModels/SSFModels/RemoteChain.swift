import Foundation

public struct XcmChain: Codable, Equatable {
    public let xcmVersion: XcmCallFactoryVersion?
    public let destWeightIsPrimitive: Bool?
    public let availableAssets: [XcmAvailableAsset]
    public let availableDestinations: [XcmAvailableDestination]

    public init(
        xcmVersion: XcmCallFactoryVersion?,
        destWeightIsPrimitive: Bool?,
        availableAssets: [XcmAvailableAsset],
        availableDestinations: [XcmAvailableDestination]
    ) {
        self.xcmVersion = xcmVersion
        self.destWeightIsPrimitive = destWeightIsPrimitive
        self.availableAssets = availableAssets
        self.availableDestinations = availableDestinations
    }

    public static func == (lhs: XcmChain, rhs: XcmChain) -> Bool {
        let sortedLhsAvailableAssets = lhs.availableAssets.sorted(by: {
            ($0.id, $0.symbol, $0.minAmount ?? "")
            >
            ($1.id, $1.symbol, $1.minAmount ?? "")
        })
        let sortedRhsAvailableAssets = rhs.availableAssets.sorted(by: {
            ($0.id, $0.symbol, $0.minAmount ?? "")
            >
            ($1.id, $1.symbol, $1.minAmount ?? "")
        })
        let isAvailableAssetsIsEqual = sortedLhsAvailableAssets.elementsEqual(sortedRhsAvailableAssets)
        
        let sortedLhsAvailableDest = lhs.availableDestinations.sorted(by: {
            $0.chainId > $1.chainId
        })
        let sortedRhsAvailableDest = rhs.availableDestinations.sorted(by: {
            $0.chainId > $1.chainId
        })
        let isAvailableDestIsEqual = sortedLhsAvailableDest.elementsEqual(sortedRhsAvailableDest)
        
        let isEqual = [
            lhs.xcmVersion == rhs.xcmVersion,
            lhs.destWeightIsPrimitive ?? false == rhs.destWeightIsPrimitive ?? false,
            isAvailableAssetsIsEqual,
            isAvailableDestIsEqual
        ].allSatisfy { $0 }
        
        return isEqual
    }
}

public struct XcmAvailableDestination: Codable, Hashable {
    public let chainId: ChainModel.Id
    public let bridgeParachainId: String?
    public let assets: [XcmAvailableAsset]

    public init(
        chainId: ChainModel.Id,
        bridgeParachainId: String?,
        assets: [XcmAvailableAsset]
    ) {
        self.chainId = chainId
        self.bridgeParachainId = bridgeParachainId
        self.assets = assets
    }
    
    public static func == (lhs: XcmAvailableDestination, rhs: XcmAvailableDestination) -> Bool {
        let sortedLhsAssets = lhs.assets.sorted(by: {
            ($0.id, $0.symbol, $0.minAmount ?? "")
            >
            ($1.id, $1.symbol, $1.minAmount ?? "")
        })
        let sortedRhsAssets = rhs.assets.sorted(by: {
            ($0.id, $0.symbol, $0.minAmount ?? "")
            >
            ($1.id, $1.symbol, $1.minAmount ?? "")
        })
        let isAvailableAssetsIsEqual = sortedLhsAssets.elementsEqual(sortedRhsAssets)

        let isEqual = [
            lhs.chainId == rhs.chainId,
            lhs.bridgeParachainId == rhs.bridgeParachainId,
            isAvailableAssetsIsEqual
        ].allSatisfy { $0 }
        
        return isEqual
    }
}

public struct XcmAvailableAsset: Codable, Hashable {
    public let id: String
    public let symbol: String
    public let minAmount: String?

    public init(id: String, symbol: String, minAmount: String?) {
        self.id = id
        self.symbol = symbol
        self.minAmount = minAmount
    }
}
