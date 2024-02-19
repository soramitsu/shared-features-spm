import Foundation
import SSFModels

public enum StorageRequestParametersType {
    case nMap(params: [[any NMapKeyParamProtocol]])
    case encodable(param: any Encodable)
    case simple
}

public protocol StorageRequest {
    var parametersType: StorageRequestParametersType { get }
    var storagePath: any StorageCodingPathProtocol { get }
}
