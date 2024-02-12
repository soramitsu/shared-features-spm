import Foundation
import SSFRuntimeCodingService
import SSFUtils
import SSFModels

protocol AsyncStorageRequestFactory {
    func queryItems<T>(
        engine: JSONRPCEngine,
        keyParams: [any Encodable],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol,
        at blockHash: Data?
    ) async throws -> [StorageResponse<T>] where T: Decodable
    
    func queryItems<K1, K2, T>(
        engine: JSONRPCEngine,
        keyParams1: [K1],
        keyParams2: [K2],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol,
        at blockHash: Data?
    ) async throws -> [StorageResponse<T>] where K1: Encodable, K2: Encodable, T: Decodable

    func queryItems<T>(
        engine: JSONRPCEngine,
        keys: [Data],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol,
        at blockHash: Data?
    ) async throws -> [StorageResponse<T>] where T: Decodable
    
    func queryChildItem<T>(
        engine: JSONRPCEngine,
        storageKeyParam: Data,
        childKeyParam: Data,
        factory: RuntimeCoderFactoryProtocol,
        mapper: DynamicScaleDecodable,
        at blockHash: Data?
    ) async throws -> ChildStorageResponse<T> where T: Decodable
    
    func queryItems<T>(
        engine: JSONRPCEngine,
        keyParams: [[NMapKeyParamProtocol]],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol,
        at blockHash: Data?
    ) async throws -> [StorageResponse<T>] where T: Decodable
    
    func queryItemsByPrefix<T>(
        engine: JSONRPCEngine,
        keys: [Data],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol,
        at blockHash: Data?
    ) async throws -> [StorageResponse<T>] where T: Decodable
}
