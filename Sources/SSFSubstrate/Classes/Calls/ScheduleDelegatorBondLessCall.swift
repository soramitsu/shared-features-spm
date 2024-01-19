import SSFUtils
import SSFModels
import BigInt

struct ScheduleDelegatorBondLessCall: Codable {
    let candidate: AccountId
    @StringCodable var less: BigUInt
}
