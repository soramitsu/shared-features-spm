import Foundation
import SSFStorageQueryKit
import SSFModels

struct PoolXykReservesStorageSingleRequest: StorageRequest {
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
        return StorageCodingPath.poolReserves
    }
}
