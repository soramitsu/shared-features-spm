import Foundation
import SSFUtils

protocol StorageRequestKeyFactory {
    func createKeyFor(_ request: StorageRequest) throws -> Data
}

final class StorageRequestKeyFactoryDefault: StorageRequestKeyFactory {
    private lazy var storageKeyFactory: StorageKeyFactoryProtocol = {
        StorageKeyFactory()
    }()
    
    private lazy var encoder = JSONEncoder()
    
    func createKeyFor(_ request: StorageRequest) throws -> Data {
        let storagePathKey = try storageKeyFactory.createStorageKey(
            moduleName: request.storagePath.moduleName,
            storageName: request.storagePath.itemName
        )
        
        switch request.parametersType {
        case .nMap(let params):
            let keys = try params.reduce([], +).map { try encoder.encode($0.value )}
            let storageKey = try keys.map {
                try storageKeyFactory.createStorageKey(
                    moduleName: request.storagePath.moduleName,
                    storageName: request.storagePath.itemName,
                    key: $0,
                    hasher: .blake128
                )
            }.joined()
            return storagePathKey + storageKey
        case .encodable(let param):
            let storageKey = try storageKeyFactory.createStorageKey(
                moduleName: request.storagePath.moduleName,
                storageName: request.storagePath.itemName,
                key: try encoder.encode(param),
                hasher: .blake128
            )
            return storagePathKey + storageKey
        case .simple:
            return storagePathKey
        }
    }
}
