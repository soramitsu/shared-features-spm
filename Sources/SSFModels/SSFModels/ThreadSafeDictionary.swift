import Foundation

public class ThreadSafeDictionary<K: Hashable, T> {
    private var dict: [K:T] = [:]
    private let queue = DispatchQueue(label: "ThreadSafeDictionaryQueue")
    
    public init() {}

    public func setValue(_ value: T, for key: K) {
        queue.async(flags: .barrier) {
            self.dict[key] = value
        }
    }

    public func value(for key: K) -> T? {
        queue.sync {
            dict[key]
        }
    }
}
