import Foundation
import SSFUtils
import SSFModels

struct CrowdloanAddMemo: Codable {
    @StringCodable var index: ParaId
    @BytesCodable var memo: Data
}
