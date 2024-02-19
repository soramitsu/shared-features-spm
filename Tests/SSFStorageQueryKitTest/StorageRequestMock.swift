import Foundation
import SSFModels
import SSFStorageQueryKit

struct StorageRequestMock: StorageRequest {
    let parametersType: StorageRequestParametersType
    let storagePath: any StorageCodingPathProtocol
}
