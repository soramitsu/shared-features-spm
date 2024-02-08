import XCTest
import SSFUtils
import SSFModels
import RobinHood
import BigInt

@testable import SSFXCM

final class XcmFeeServiceTests: XCTestCase {
    
    var service: XcmDestinationFeeFetching?
    var factory: NetworkOperationFactoryProtocolMock<[XcmFee]>?
    
    override func setUp() {
        super.setUp()
        
        let factory = NetworkOperationFactoryProtocolMock<[XcmFee]>()
        factory.fetchDataFromReturnValue = createOperation()
        self.factory = factory
        
        service = XcmDestinationFeeFetcher(sourceUrl: XcmConfig.shared.chainsSourceUrl,
                                           networkOperationFactory: factory,
                                           operationQueue: OperationQueue())
    }
    
    override func tearDown() {
        super.tearDown()
        factory = nil
        service = nil
    }
    
    func testEstimateFee() async {
        // arrange
        let destinationChainId: String = "0"
        let token: String = "xc0"
        
        // act
        let result = await service?.estimateFee(destinationChainId: destinationChainId,
                                                token: token)
        
        // assert
        XCTAssertNotNil(result)
        
        switch result {
        case .success(let destXcmFee):
            XCTAssertEqual(destXcmFee, TestData.destXcmFee)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        case .none:
            XCTFail()
        }
    }
    
    func testEstimateWeight() async throws {
        // arrange
        let chainId: String = "0"
        
        // act
        let weight = try await service?.estimateWeight(for: chainId)
        
        // assert
        XCTAssertNotNil(weight)
        XCTAssertEqual(weight, TestData.xcmFee.weight)
       
    }
}

private extension XcmFeeServiceTests {
    private enum TestData {
        static let destXcmFee = DestXcmFee(feeInPlanks: BigUInt(),
                                           symbol: "0",
                                           precision: "0")
        
        static let xcmFee = XcmFee(chainId: "0",
                                   destChain: "0",
                                   destXcmFee: [.init(feeInPlanks: BigUInt(),
                                                      symbol: "0",
                                                      precision: "0")],
                                   weight: BigUInt())
    }
    
    private func createOperation() -> BaseOperation<[XcmFee]> {
        let operation = ClosureOperation {
            return [TestData.xcmFee]
        }
        
        return operation
    }
}

