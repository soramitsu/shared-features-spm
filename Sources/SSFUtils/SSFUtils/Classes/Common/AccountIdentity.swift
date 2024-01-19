import Foundation
import SSFModels

public struct AccountIdentity: Equatable, Decodable {
    let name: String
    let parentAddress: AccountAddress?
    let parentName: String?
    let legal: String?
    let web: String?
    let riot: String?
    let email: String?
    let image: Data?
    let twitter: String?

    init(
        name: String,
        parentAddress: AccountAddress? = nil,
        parentName: String? = nil,
        identity: IdentityInfo? = nil
    ) {
        self.name = name
        self.parentAddress = parentAddress
        self.parentName = parentName
        legal = identity?.legal.stringValue
        web = identity?.web.stringValue
        riot = identity?.riot.stringValue
        email = identity?.email.stringValue
        image = identity?.image.dataValue
        twitter = identity?.twitter.stringValue
    }

    var displayName: String {
        if let parentName = parentName {
            return parentName + " / " + name
        } else {
            return name
        }
    }
}

extension ChainData {
    var stringValue: String? {
        switch self {
        case .none:
            return nil
        case let .raw(data):
            return String(data: data, encoding: .utf8)
        case let .blakeTwo256(data), let .keccak256(data),
             let .sha256(data), let .shaThree256(data):
            return data.value.toHex(includePrefix: true)
        }
    }

//    var imageValue: UIImage? {
//        if case let .raw(data) = self {
//            return UIImage(data: data)
//        } else {
//            return nil
//        }
//    }
//
    var dataValue: Data? {
        switch self {
        case .none:
            return nil
        case let .raw(data):
            return data
        case let .blakeTwo256(hash), let .keccak256(hash),
             let .sha256(hash), let .shaThree256(hash):
            return hash.value
        }
    }
}
