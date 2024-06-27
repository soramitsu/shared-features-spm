import Foundation
import SSFModels
import SSFStorageQueryKit

struct PoolXykPoolProvidersStorageSingleRequest: StorageRequest {
    let pair: AssetIdPair
    
    var parametersType: SSFStorageQueryKit.StorageRequestParametersType {
        let params =
            [
                [NMapKeyParam(value: pair.baseAssetId)],
                [NMapKeyParam(value: pair.targetAssetId)]
            ]
        
        return .nMap(params: params)
    }
    
    var storagePath: any SSFModels.StorageCodingPathProtocol {
        return SSFPolkaswap.StorageCodingPath.poolProperties
    }
    
    
}
