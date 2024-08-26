import Foundation
import SSFModels
import SSFStorageQueryKit

struct PoolXykTotalIssuanceStoragePagedRequest: PrefixRequest {
    var keyType: SSFStorageQueryKit.MapKeyType {
        .accountId
    }

    var parametersType: SSFStorageQueryKit.PrefixStorageRequestParametersType {
        .simple
    }

    var storagePath: any SSFModels.StorageCodingPathProtocol {
        SSFPolkaswap.StorageCodingPath.poolTotalIssuances
    }
}
