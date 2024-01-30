import Foundation

public struct ChainNodeModel: Equatable, Codable, Hashable {
    public let url: URL
    public let name: String
    public let apikey: String?
    
    public init(url: URL, name: String, apikey: String) {
        self.url = url
        self.name = name
        self.apikey = apikey
    }
    
}

public extension ChainNodeModel {
    var clearUrlString: String? {
        url.absoluteString.components(separatedBy: "?api").first
    }
}
