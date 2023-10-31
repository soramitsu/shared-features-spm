import Foundation
import SSFUtils

public struct RuntimeSnapshot {
    public let typeRegistryCatalog: TypeRegistryCatalogProtocol
    public let specVersion: UInt32
    public let txVersion: UInt32
    public let metadata: RuntimeMetadata
    
    public var runtimeSpecVersion: RuntimeSpecVersion {
        RuntimeSpecVersion(rawValue: specVersion) ?? RuntimeSpecVersion.defaultVersion
    }
}
