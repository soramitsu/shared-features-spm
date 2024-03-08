import XCTest
import SSFNetwork
import MocksBasket
import SSFModels

@testable import SSFIndexers

final class AlchemyHistoryServiceTests: BaseHistoryService {
    
    private var expectedResponse: AlchemyResponse<AlchemyHistory> {
        get throws {
            try getResponse(file: "alchemy")
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
            blockExplorerType: .alchemy,
            assetSymbol: "eth",
            precision: 1,
            ethereumType: nil,
            contractaddress: nil
        )
        
        let history = try await historyService?.fetchTransactionHistory(
            chainAsset: chainAsset,
            address: "0xa150ea05b1a515433a6426f309ab1bc5dc62a014",
            filters: [],
            pagination: Pagination.init(count: 100)
        )
        try history?.transactions.forEach({ item in
            XCTAssertTrue(try expectedResponse.result.transfers.contains(where: { $0.uniqueId == item.transactionId }))
        })
    }
    
    private func setupServices() throws {
        guard historyService == nil || networkWorker == nil else {
            return
        }
        let networkWorker = NetworkWorkerMock<AlchemyResponse<AlchemyHistory>>()
        networkWorker.performRequestWithReturnValue = try expectedResponse
        super.networkWorker = networkWorker
        let service = AlchemyHistoryService(networkWorker: networkWorker)
        super.historyService = service
    }
}
