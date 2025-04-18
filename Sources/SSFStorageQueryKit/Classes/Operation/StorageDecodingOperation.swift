import Foundation
import RobinHood
import SSFModels
import SSFRuntimeCodingService
import SSFUtils

enum StorageDecodingOperationError: Error {
    case missingRequiredParams
    case invalidStoragePath
}

protocol StorageDecodable {
    func decode(
        data: Data,
        path: any StorageCodingPathProtocol,
        codingFactory: RuntimeCoderFactoryProtocol
    ) throws -> JSON
}

extension StorageDecodable {
    func decode(
        data: Data,
        path: any StorageCodingPathProtocol,
        codingFactory: RuntimeCoderFactoryProtocol
    ) throws -> JSON {
        guard let entry = codingFactory.metadata.getStorageMetadata(
            in: path.moduleName,
            storageName: path.itemName
        ) else {
            throw StorageDecodingOperationError.invalidStoragePath
        }

        let decoder = try codingFactory.createDecoder(from: data)
        let type = try entry.type.typeName(using: codingFactory.metadata.schemaResolver)
        return try decoder.read(type: type)
    }
}

protocol StorageModifierHandling {
    func handleModifier(
        at path: any StorageCodingPathProtocol,
        codingFactory: RuntimeCoderFactoryProtocol
    ) throws -> JSON?
}

extension StorageModifierHandling {
    func handleModifier(
        at path: any StorageCodingPathProtocol,
        codingFactory: RuntimeCoderFactoryProtocol
    ) throws -> JSON? {
        guard let entry = codingFactory.metadata.getStorageMetadata(
            in: path.moduleName,
            storageName: path.itemName
        ) else {
            throw StorageDecodingOperationError.invalidStoragePath
        }

        switch entry.modifier {
        case .defaultModifier:
            let decoder = try codingFactory.createDecoder(from: entry.defaultValue)
            let type = try entry.type.typeName(using: codingFactory.metadata.schemaResolver)
            return try decoder.read(type: type)
        case .optional:
            return nil
        }
    }
}

public final class StorageDecodingOperation<T: Decodable>: BaseOperation<T>, StorageDecodable {
    var data: Data?
    public var codingFactory: RuntimeCoderFactoryProtocol?

    public let path: any StorageCodingPathProtocol

    public init(path: any StorageCodingPathProtocol, data: Data? = nil) {
        self.path = path
        self.data = data

        super.init()
    }

    override public func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            guard let data = data, let factory = codingFactory else {
                throw StorageDecodingOperationError.missingRequiredParams
            }

            let item = try decode(data: data, path: path, codingFactory: factory).map(to: T.self)
            result = .success(item)
        } catch {
            result = .failure(error)
        }
    }
}

final class StorageFallbackDecodingOperation<T: Decodable>: BaseOperation<T?>,
    StorageDecodable, StorageModifierHandling
{
    var data: Data?
    var codingFactory: RuntimeCoderFactoryProtocol?

    let path: any StorageCodingPathProtocol

    init(path: any StorageCodingPathProtocol, data: Data? = nil) {
        self.path = path
        self.data = data

        super.init()
    }

    override func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            guard let factory = codingFactory else {
                throw StorageDecodingOperationError.missingRequiredParams
            }

            if let data = data {
                let item = try decode(data: data, path: path, codingFactory: factory)
                    .map(to: T.self)
                result = .success(item)
            } else {
                let item = try handleModifier(at: path, codingFactory: factory)?.map(to: T.self)
                result = .success(item)
            }

        } catch {
            result = .failure(error)
        }
    }
}

final class StorageDecodingListOperation<T: Decodable>: BaseOperation<[T]>, StorageDecodable {
    var dataList: [Data]?
    var codingFactory: RuntimeCoderFactoryProtocol?

    let path: any StorageCodingPathProtocol

    init(path: any StorageCodingPathProtocol, dataList: [Data]? = nil) {
        self.path = path
        self.dataList = dataList

        super.init()
    }

    override func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            guard let dataList = dataList, let factory = codingFactory else {
                throw StorageDecodingOperationError.missingRequiredParams
            }

            let items: [T] = try dataList.map { try decode(
                data: $0,
                path: path,
                codingFactory: factory
            )
            .map(to: T.self)
            }

            result = .success(items)
        } catch {
            result = .failure(error)
        }
    }
}

final class StorageFallbackDecodingListOperation<T: Decodable>: BaseOperation<[T?]>,
    StorageDecodable, StorageModifierHandling
{
    var dataList: [Data?]?
    var codingFactory: RuntimeCoderFactoryProtocol?

    let path: any StorageCodingPathProtocol

    init(path: any StorageCodingPathProtocol, dataList: [Data?]? = nil) {
        self.path = path
        self.dataList = dataList

        super.init()
    }

    override func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            guard let dataList = dataList, let factory = codingFactory else {
                throw StorageDecodingOperationError.missingRequiredParams
            }

            let items: [T?] = try dataList.map { data in
                if let data = data {
                    return try decode(data: data, path: path, codingFactory: factory)
                        .map(to: T.self)
                } else {
                    return try handleModifier(at: path, codingFactory: factory)?.map(to: T.self)
                }
            }

            result = .success(items)
        } catch {
            result = .failure(error)
        }
    }
}

protocol ConstantDecodable {
    func decode(at path: ConstantCodingPath, codingFactory: RuntimeCoderFactoryProtocol) throws
        -> JSON
}

extension ConstantDecodable {
    func decode(
        at path: ConstantCodingPath,
        codingFactory: RuntimeCoderFactoryProtocol
    ) throws -> JSON {
        guard let entry = codingFactory.metadata.getConstant(
            in: path.moduleName,
            constantName: path.constantName
        ) else {
            throw StorageDecodingOperationError.invalidStoragePath
        }

        let decoder = try codingFactory.createDecoder(from: entry.value)
        let type = try entry.type(using: codingFactory.metadata.schemaResolver)
        return try decoder.read(type: type)
    }
}

final class StorageConstantOperation<T: Decodable>: BaseOperation<T>, ConstantDecodable {
    var codingFactory: RuntimeCoderFactoryProtocol?

    let path: ConstantCodingPath

    init(path: ConstantCodingPath) {
        self.path = path

        super.init()
    }

    override func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            guard let factory = codingFactory else {
                throw StorageDecodingOperationError.missingRequiredParams
            }

            let item: T = try decode(at: path, codingFactory: factory).map(to: T.self)
            result = .success(item)
        } catch {
            result = .failure(error)
        }
    }
}

public final class PrimitiveConstantOperation<
    T: LosslessStringConvertible &
        Equatable
>: BaseOperation<T>, ConstantDecodable {
    public var codingFactory: RuntimeCoderFactoryProtocol?

    let path: ConstantCodingPath

    public init(path: ConstantCodingPath) {
        self.path = path

        super.init()
    }

    override public func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        do {
            guard let factory = codingFactory else {
                throw StorageDecodingOperationError.missingRequiredParams
            }

            let item: StringCodable<T> = try decode(at: path, codingFactory: factory)
                .map(to: StringCodable<T>.self)
            result = .success(item.wrappedValue)
        } catch {
            result = .failure(error)
        }
    }
}
