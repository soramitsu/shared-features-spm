import Foundation

public enum CachedNetworkResponseType {
    case cache
    case remote
}

public struct CachedNetworkResponse<T> {
    public var value: T?
    public var type: CachedNetworkResponseType
    
    public static var empty: CachedNetworkResponse<T> {
        return CachedNetworkResponse(value: nil, type: .cache)
    }
    
    public init(value: T?, type: CachedNetworkResponseType) {
        self.value = value
        self.type = type
    }
    
    public func merge(with previous: CachedNetworkResponse<T>?, priorityType: CachedNetworkResponseType) -> CachedNetworkResponse<T> {
        var type: CachedNetworkResponseType
        switch (previous?.type, self.type) {
        case (.cache, .cache):
            type = .cache
        case (.remote, .remote):
            type = .remote
        case (.cache, .remote):
            type = .remote
        case (.remote, .cache):
            type = priorityType
        case (nil, .cache):
            type = .cache
        case (nil, .remote):
            type = .remote
        }
        
        return CachedNetworkResponse(value: value, type: type)
    }
}
