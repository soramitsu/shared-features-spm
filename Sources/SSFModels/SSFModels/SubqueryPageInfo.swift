import Foundation

public struct SubqueryPageInfo: Decodable {
    public let startCursor: String?
    public let endCursor: String?
    public let hasNextPage: Bool?

    public func toContext() -> [String: String]? {
        if startCursor == nil, endCursor == nil {
            return nil
        }
        var context: [String: String] = [:]
        if let startCursor = startCursor {
            context["startCursor"] = startCursor
        }

        if let endCursor = endCursor {
            context["endCursor"] = endCursor
        }

        return context
    }
}
