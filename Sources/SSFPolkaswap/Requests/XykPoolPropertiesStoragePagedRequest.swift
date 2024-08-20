import Foundation
import SSFModels
import SSFStorageQueryKit
import SSFUtils

public struct XykPoolPropertiesStoragePagedRequest: PrefixRequest {
    public var keyType: SSFStorageQueryKit.MapKeyType {
        .assetIds
    }

    let baseAssetIds: [PolkaswapDexInfoAssetId]

    public var parametersType: PrefixStorageRequestParametersType {
        .encodable(params: baseAssetIds)
    }

    public var storagePath: any SSFModels.StorageCodingPathProtocol {
        SSFPolkaswap.StorageCodingPath.poolProperties
    }
}
