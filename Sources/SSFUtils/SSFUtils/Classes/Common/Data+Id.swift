import Foundation

extension [Data] {
    public func createId() -> String {
        let result = NSMutableData()
        self.forEach { data in
            result.append(data)
        }
        return String(result.hashValue)
    }
}
