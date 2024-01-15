import Foundation
import SSFModels

struct SeedExportData {
    let seed: Data
    let derivationPath: String?
    let chain: ChainModel
    let cryptoType: CryptoType
}
