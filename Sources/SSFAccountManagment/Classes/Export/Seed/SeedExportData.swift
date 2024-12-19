import Foundation
import SSFModels

public struct SeedExportData {
    let seed: Data
    let derivationPath: String?
    let chain: ChainModel
    let cryptoType: CryptoType
}
