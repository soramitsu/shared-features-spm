import Foundation
import SSFUtils

enum StorageRequestWorkerError: Error {
    case invalidParameters
}

protocol StorageRequestWorker: AnyObject {
    func perform<T: Decodable>(request: some StorageRequest) async throws -> [StorageResponse<T>]
}
