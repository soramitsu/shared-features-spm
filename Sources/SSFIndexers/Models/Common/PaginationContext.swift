import Foundation

//public struct Pagination: Codable, Equatable {
//    public let totalRecords: Int?
//    public let currentPage: Int?
//    public let nextPage: Int?
//    public let previousPage: Int?
//}

public struct Pagination: Codable, Equatable {
    public let context: PaginationContext?
    public let count: Int

    public init(count: Int, context: [String: String]? = nil) {
        self.count = count
        self.context = context
    }
}
