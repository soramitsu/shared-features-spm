import Foundation

public enum JSONResponseDecoderError: Error {
    case typeNotDecodable
}

open class JSONResponseDecoder: ResponseDecoder {
    let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }

    open func decode<T>(data: Data) throws -> T {
        guard let type = T.self as? Decodable.Type else {
            throw JSONResponseDecoderError.typeNotDecodable
        }

        let obj = try jsonDecoder.decode(type, from: data)

        guard let decoded = obj as? T else {
            throw JSONResponseDecoderError.typeNotDecodable
        }

        return decoded
    }
}
