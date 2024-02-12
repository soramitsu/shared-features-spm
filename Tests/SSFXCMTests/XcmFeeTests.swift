import XCTest
import BigInt

@testable import SSFXCM

final class XcmFeeTests: XCTestCase {
    
    func testXcmFeeInit() {
        // arrange
        let chainId: String = "1"
        let destChain: String = "1"
        let destXcmFee: [DestXcmFee] = [DestXcmFee(symbol: "symbol", precision: "precision")]
        let weight: BigUInt = BigUInt()
        
        // act
        let fee = XcmFee(chainId: chainId,
                         destChain: destChain,
                         destXcmFee: destXcmFee,
                         weight: weight)
        
        // assert
        XCTAssertEqual(fee.chainId, chainId)
        XCTAssertEqual(fee.destChain, destChain)
        XCTAssertEqual(fee.destXcmFee, destXcmFee)
        XCTAssertEqual(fee.weight, weight)
    }
    
    func testDestXcmFeeInit() {
        // arrange
        let feeInPlanks: BigUInt = BigUInt()
        let symbol: String = "1"
        let precision: String = "2"
        
        // act
        let destXcmFee = DestXcmFee(feeInPlanks: feeInPlanks,
                                    symbol: symbol,
                                    precision: precision)
        
        // assert
        XCTAssertEqual(destXcmFee.feeInPlanks, feeInPlanks)
        XCTAssertEqual(destXcmFee.symbol, symbol)
        XCTAssertEqual(destXcmFee.precision, precision)
    }
}
