import Foundation
import Combine

public protocol PoolsService {
    var pairsPublisher: Published<[LiquidityPair]>.Publisher { get }
    func subscribeAllPairs() async throws
    
    var accountPoolsPublisher: Published<[AccountPool]>.Publisher { get }
    func subscribeAccountPools(accountId: Data) async throws
    
    var poolDetailsPublisher: Published<AccountPool?>.Publisher { get }
    func subscribeAccountPoolDetails(accountId: Data, baseAssetId: String, targetAssetId: String) async throws
}
