import Foundation
import IrohaCrypto

public extension Data {
    func toHex(includePrefix: Bool = false) -> String {
        (includePrefix ? "0x" : "") + (self as NSData).toHexString()
    }

    init(hexStringSSF: String) throws {
        let prefix = "0x"
        if hexStringSSF.hasPrefix(prefix) {
            let filtered = String(hexStringSSF.suffix(hexStringSSF.count - prefix.count))
            self = try (NSData(hexString: filtered)) as Data
        } else {
            self = try (NSData(hexString: hexStringSSF)) as Data
        }
    }
    
    init?(tonHex: String) {
        let len = tonHex.count / 2
        var data = Data(capacity: len)
        var i = tonHex.startIndex
        
        for _ in 0..<len {
            let j = tonHex.index(i, offsetBy: 2)
            let bytes = tonHex[i..<j]
            
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            
            i = j
        }
        
        self = data
    }
}
