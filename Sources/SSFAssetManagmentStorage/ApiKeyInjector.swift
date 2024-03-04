import Foundation
import SSFModels

// sourcery: AutoMockable
public protocol ApiKeyInjector {
    func getBlockExplorerKey(
        for type: BlockExplorerType,
        chainId: ChainModel.Id
    ) -> String?
}
