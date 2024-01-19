import Foundation
import SSFUtils
import SSFModels
import BigInt

struct CrowdloanContributeCall: Codable {
    @StringCodable var index: ParaId
    @StringCodable var value: BigUInt
    @NullCodable var signature: MultiSignature?
}
