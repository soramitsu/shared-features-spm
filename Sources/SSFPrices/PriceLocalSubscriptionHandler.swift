import Foundation
import SSFModels

protocol PriceLocalSubscriptionHandler: AnyObject {
    func handlePrices(result: Result<[PriceData], Error>, for chainAssets: [ChainAsset])
}
