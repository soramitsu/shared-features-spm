import Foundation
import BigInt
import SSFModels
import SSFUtils

struct XTokensTransferCall: Codable {
    let currencyId: CurrencyId
    @StringCodable var amount: BigUInt
    let dest: XcmVersionedMultiLocation
    let destWeightLimit: XcmWeightLimit?
}
