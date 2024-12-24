import Foundation
import TonSwift

public extension TonSwift.Address {
    static func random() -> TonSwift.Address {
        TonSwift.Address.mock(workchain: 0, seed: "testResolvableAddressResolvedCoding")
    }

    func asAccountId() throws -> AccountId {
        guard let data = toRaw().data(using: .utf8) else {
            throw NSError(domain: "Wrong address", code: 0)
        }
        return data
    }
}

public extension AccountId {
    func asTonAddress() throws -> TonSwift.Address {
        guard let raw = String(data: self, encoding: .utf8) else {
            throw NSError(domain: "Wrong raw", code: 0)
        }
        return try TonSwift.Address.parse(raw)
    }
}
