import Foundation
import IrohaCrypto
import RobinHood
import sorawallet

protocol PolkaswapAPYService: Actor {
    func getApy(reservesId: String) async throws -> Decimal?
}

actor PolkaswapAPYServiceImpl {
    private let worker: PolkaswapAPYWorker
    private var apyCache: [String: Decimal?] = [:]
    
    init(worker: PolkaswapAPYWorker) {
        self.worker = worker
    }
}

extension PolkaswapAPYServiceImpl: PolkaswapAPYService {

    func getApy(reservesId: String) async throws -> Decimal? {
        if let apy = apyCache[reservesId] {
            return apy
        }
        
        let apyInfo = try await worker.getAPYInfo()

        apyInfo.forEach { apy in
            apyCache[apy.id] = apy.sbApy?.decimalValue
        }

        return apyCache[reservesId] ?? nil
    }
}
