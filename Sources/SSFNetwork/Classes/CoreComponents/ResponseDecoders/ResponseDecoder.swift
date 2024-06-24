import Foundation

public protocol ResponseDecoder {
    func decode<T>(data: Data) throws -> T
}
