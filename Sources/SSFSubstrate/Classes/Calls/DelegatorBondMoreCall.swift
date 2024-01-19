import Foundation
import SSFUtils
import SSFModels
import BigInt

struct DelegatorBondMoreCall: Codable {
    let candidate: AccountId
    @StringCodable var more: BigUInt
}
