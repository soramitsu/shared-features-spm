import Foundation
import SSFModels
import SSFStorageQueryKit

struct StorageRequestMock: StorageRequest {
    let parametersType: StorageRequestParametersType
    let storagePath: any StorageCodingPathProtocol
}

struct MultipleStorageRequstMock: MultipleRequest {
    var keyType: SSFStorageQueryKit.MapKeyType
    let parametersType: MultipleStorageRequestParametersType
    let storagePath: any StorageCodingPathProtocol
}
