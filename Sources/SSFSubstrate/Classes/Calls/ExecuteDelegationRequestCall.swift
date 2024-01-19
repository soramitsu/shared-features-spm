import Foundation
import SSFUtils
import SSFModels

struct ExecuteDelegationRequestCall: Codable {
    let delegator: AccountId
    let candidate: AccountId
}
