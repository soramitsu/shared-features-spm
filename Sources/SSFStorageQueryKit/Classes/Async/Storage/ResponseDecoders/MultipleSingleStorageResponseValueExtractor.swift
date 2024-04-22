import Foundation
import SSFRuntimeCodingService
import SSFUtils

final class MultipleSingleStorageResponseValueExtractor: MultipleStorageResponseValueExtractor {
    
    private let runtimeService: RuntimeCodingServiceProtocol

    init(runtimeService: RuntimeCodingServiceProtocol) {
        self.runtimeService = runtimeService
    }
    
    func extractValue<T, K>(request: MultipleRequest, storageResponse: [StorageResponse<T>]) async throws -> [K : T] where T : Decodable, K : ScaleDecodable, K : ScaleEncodable, K : Decodable, K : Hashable {
        var dict: [K: T] = [:]
        let keyExtractor = StorageKeyDataExtractor(runtimeService: runtimeService)
        
        try await storageResponse.asyncForEach {
            let id: K = try await keyExtractor.extractKey(
                storageKey: $0.key,
                storagePath: request.storagePath,
                type: request.keyType
            )
                        
            dict[id] = $0.value
        }
        
        return dict
    }
}
