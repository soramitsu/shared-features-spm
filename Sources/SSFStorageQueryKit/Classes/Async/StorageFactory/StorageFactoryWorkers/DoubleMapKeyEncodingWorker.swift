import Foundation
import SSFRuntimeCodingService
import SSFModels
import SSFUtils

final class DoubleMapKeyEncodingWorker<T1: Encodable, T2: Encodable> {
    private let keyParams1: [T1]
    private let keyParams2: [T2]
    private let codingFactory: RuntimeCoderFactoryProtocol
    private let path: any StorageCodingPathProtocol
    private let storageKeyFactory: StorageKeyFactoryProtocol

    init(
        codingFactory: RuntimeCoderFactoryProtocol,
        path: any StorageCodingPathProtocol,
        storageKeyFactory: StorageKeyFactoryProtocol,
        keyParams1: [T1],
        keyParams2: [T2]
    ) {
        self.codingFactory = codingFactory
        self.path = path
        self.keyParams1 = keyParams1
        self.keyParams2 = keyParams2
        self.storageKeyFactory = storageKeyFactory
    }

    func performEncoding() throws -> [Data] {
        guard let entry = codingFactory.metadata.getStorageMetadata(
            in: path.moduleName,
            storageName: path.itemName
        ) else {
            throw StorageKeyEncodingOperationError.invalidStoragePath
        }
        
        guard case let .doubleMap(doubleMapEntry) = entry.type else {
            throw StorageKeyEncodingOperationError.incompatibleStorageType
        }
        
        let keys: [Data] = try zip(keyParams1, keyParams2).map { param in
            let encodedParam1 = try encodeParam(
                param.0,
                factory: codingFactory,
                type: doubleMapEntry.key1
            )
            
            let encodedParam2 = try encodeParam(
                param.1,
                factory: codingFactory,
                type: doubleMapEntry.key2
            )
            
            return try storageKeyFactory.createStorageKey(
                moduleName: path.moduleName,
                storageName: path.itemName,
                key1: encodedParam1,
                hasher1: doubleMapEntry.hasher,
                key2: encodedParam2,
                hasher2: doubleMapEntry.key2Hasher
            )
        }
        
        return keys
    }

    private func encodeParam<T: Encodable>(
        _ param: T,
        factory: RuntimeCoderFactoryProtocol,
        type: String
    ) throws -> Data {
        let encoder = factory.createEncoder()
        try encoder.append(param, ofType: type)
        return try encoder.encode()
    }
}
