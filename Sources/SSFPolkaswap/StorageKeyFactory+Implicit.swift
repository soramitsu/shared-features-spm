import SSFUtils
import SSFModels
import Foundation

extension StorageKeyFactoryProtocol {
    func xykPoolKeyReserves(asset: Data) throws -> Data {
        try createStorageKey(moduleName: "PoolXYK",
                             storageName: "Reserves",
                             key: asset,
                             hasher: .blake128Concat)
    }
    
    func key(from codingPath: StorageCodingPath) throws -> Data {
        try createStorageKey(moduleName: codingPath.moduleName, storageName: codingPath.itemName)
    }
 }
