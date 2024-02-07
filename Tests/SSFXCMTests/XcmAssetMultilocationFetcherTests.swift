import XCTest

@testable import SSFXCM

final class XcmAssetMultilocationFetcherTests: XCTestCase {
    
    var fetcher: XcmAssetMultilocationFetching?
    var dataFetchFactory: NetworkOperationFactoryProtocolMock?
    var retryStrategy: ReconnectionStrategyProtocolMock?
    
    override func setUp() {
        super.setUp()
        
        let dataFetchFactory = NetworkOperationFactoryProtocolMock()
        let retryStrategy = ReconnectionStrategyProtocolMock()
        
        self.dataFetchFactory = dataFetchFactory
        self.retryStrategy = retryStrategy
        
        fetcher = XcmAssetMultilocationFetcher(sourceUrl: XcmConfig.shared.tokenLocationsSourceUrl,
                                               dataFetchFactory: dataFetchFactory,
                                               retryStrategy: retryStrategy,
                                               operationQueue: OperationQueue())
    }
    
    override func tearDown() {
        super.tearDown()
        fetcher = nil
        dataFetchFactory = nil
        retryStrategy = nil
    }
    
    func testXcmAssetMultilocationFetcherInit() {
        // arrange
        let url = XcmConfig.shared.tokenLocationsSourceUrl
        let fetchFactory = NetworkOperationFactoryProtocolMock()
        let reconnectionStrategy = ReconnectionStrategyProtocolMock()
        let queue = OperationQueue()
        
        // act
        let assetFetcher = XcmAssetMultilocationFetcher(sourceUrl: url,
                                                        dataFetchFactory: fetchFactory,
                                                        retryStrategy: reconnectionStrategy,
                                                        operationQueue: queue)
        
        // assert
        XCTAssertNotNil(assetFetcher)
        XCTAssertEqual(fetchFactory.fetchDataFromCallsCount, 1)
        XCTAssertTrue(fetchFactory.fetchDataFromCalled)
    }
    
    func testVersionedMultilocation() async throws {
        
    }
}
