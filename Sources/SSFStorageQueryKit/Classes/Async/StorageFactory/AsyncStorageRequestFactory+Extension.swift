import Foundation
import SSFRuntimeCodingService
import SSFUtils
import SSFModels

extension AsyncStorageRequestFactory {
    func queryItems<T>(
        engine: JSONRPCEngine,
        keyParams: [any Encodable],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [StorageResponse<T>] where T: Decodable {
        try await queryItems(
            engine: engine,
            keyParams: keyParams,
            factory: factory,
            storagePath: storagePath,
            at: nil
        )
    }

    func queryItems<K1, K2, T>(
        engine: JSONRPCEngine,
        keyParams1: [K1],
        keyParams2: [K2],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [StorageResponse<T>] where K1: Encodable, K2: Encodable, T: Decodable {
        try await queryItems(
            engine: engine,
            keyParams1: keyParams1,
            keyParams2: keyParams2,
            factory: factory,
            storagePath: storagePath,
            at: nil
        )
    }

    func queryItems<T>(
        engine: JSONRPCEngine,
        keyParams: [[any NMapKeyParamProtocol]],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [StorageResponse<T>] where T: Decodable {
        try await queryItems(
            engine: engine,
            keyParams: keyParams,
            factory: factory,
            storagePath: storagePath,
            at: nil
        )
    }

    func queryItems<T>(
        engine: JSONRPCEngine,
        keys: [Data],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [StorageResponse<T>] where T: Decodable {
        try await queryItems(
            engine: engine,
            keys: keys,
            factory: factory,
            storagePath: storagePath,
            at: nil
        )
    }

    func queryItemsByPrefix<T>(
        engine: JSONRPCEngine,
        keys: [Data],
        factory: RuntimeCoderFactoryProtocol,
        storagePath: any StorageCodingPathProtocol
    ) async throws -> [StorageResponse<T>] where T: Decodable {
        try await queryItemsByPrefix(
            engine: engine,
            keys: keys,
            factory: factory,
            storagePath: storagePath,
            at: nil
        )
    }

    func queryChildItem<T>(
        engine: JSONRPCEngine,
        storageKeyParam: Data,
        childKeyParam: Data,
        factory: RuntimeCoderFactoryProtocol,
        mapper: DynamicScaleDecodable
    ) async throws -> ChildStorageResponse<T> where T: Decodable {
        try await queryChildItem(
            engine: engine,
            storageKeyParam: storageKeyParam,
            childKeyParam: childKeyParam,
            factory: factory,
            mapper: mapper,
            at: nil
        )
    }
}
