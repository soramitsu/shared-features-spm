import Foundation

protocol StorageResponseDecoderFactory {
    func buildResponseDecoder(for request: some StorageRequest) throws -> StorageResponseDecoder
}

final class StorageResponseDecoderFactoryDefault: StorageResponseDecoderFactory {
    func buildResponseDecoder(for request: some StorageRequest) throws -> StorageResponseDecoder {
        switch request.responseType {
        case .single:
            return StorageSingleResponseDecoder()
        }
    }
}
