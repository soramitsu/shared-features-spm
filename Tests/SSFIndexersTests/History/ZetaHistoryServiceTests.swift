import XCTest
import SSFNetwork
import MocksBasket
import SSFModels

@testable import SSFIndexers

final class ZetaHistoryServiceTests: BaseHistoryService {
    
    private var expectedResponse: ZetaHistoryResponse {
        get throws {
            try getResponse(file: "zeta")
        }
    }

    override func setUpWithError() throws {
        try setupServices()
    }

    override func tearDownWithError() throws {
        networkWorker = nil
        historyService = nil
    }

    func test() async throws {
        let chainAsset = chainAsset(
            blockExplorerType: .zeta,
            assetSymbol: "eth",
            precision: 1,
            ethereumType: nil,
            contractaddress: "13"
        )
        
        let history = try await historyService?.fetchTransactionHistory(
            chainAsset: chainAsset,
            address: "0xa150ea05b1a515433a6426f309ab1bc5dc62a014",
            filters: [],
            pagination: Pagination.init(count: 100)
        )
        XCTAssertEqual(history?.transactions.count, 13)
    }
    
    private func setupServices() throws {
        guard historyService == nil || networkWorker == nil else {
            return
        }
        let networkWorker = NetworkWorkerMock<ZetaHistoryResponse>()
        networkWorker.performRequestWithReturnValue = try expectedResponse
        super.networkWorker = networkWorker
        let service = ZetaHistoryService(networkWorker: networkWorker)
        super.historyService = service
    }
}
