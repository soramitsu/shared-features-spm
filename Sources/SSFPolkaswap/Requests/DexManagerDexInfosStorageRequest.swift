import Foundation
import SSFModels
import SSFStorageQueryKit

struct DexManagerDexInfosStorageRequest: PrefixRequest {
    var storagePath: any SSFModels.StorageCodingPathProtocol {
        SSFPolkaswap.StorageCodingPath.dexInfos
    }

    var keyType: SSFStorageQueryKit.MapKeyType {
        .u32
    }

    var parametersType: PrefixStorageRequestParametersType {
        .simple
    }
}
