import Foundation
import SSFModels

struct SoraSubqueryApyInfoResponse: Decodable {
    let entities: SoraSubqueryApyInfoPage
}

struct SoraSubqueryApyInfoPage: Decodable {
    let nodes: [PoolApyInfo]
    let pageInfo: SubqueryPageInfo
}
