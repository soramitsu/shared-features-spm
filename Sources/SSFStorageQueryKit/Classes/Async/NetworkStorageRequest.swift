import Foundation
import SSFModels

public enum StorageResponseType {
    case single
}

public enum StorageRequestParametersType<K: Encodable> {
    case nMap(params: [[any NMapKeyParamProtocol]])
    case encodable(params: [K])
    case keys(params: [Data])
}

public protocol StorageRequest {
    /*
     TODO: think about more convenient solution
     K - type of input parameter for encodable request parameter type. For another parameter types just use mock e.g. Data type
     */
    associatedtype K: Encodable
    var parametersType: StorageRequestParametersType<K> { get }
    var storagePath: any StorageCodingPathProtocol { get }
    var responseType: StorageResponseType { get }
}
