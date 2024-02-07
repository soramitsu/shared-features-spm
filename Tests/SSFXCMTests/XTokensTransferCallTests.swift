import XCTest
import SSFModels
import BigInt

@testable import SSFXCM

final class XTokensTransferCallTests: XCTestCase {
    
    func testXTokensTransferCallInit() {
        // arrange
        let currencyId: CurrencyId = .xcm(id: "1")
        let amount: BigUInt = BigUInt()
        let dest: XcmVersionedMultiLocation = .V1(.init(parents: 0, interior: .init(items: [.onlyChild])))
        let destWeightLimit: XcmWeightLimit = .unlimited
        
        // act
        let call = XTokensTransferCall(currencyId: currencyId,
                                       amount: amount,
                                       dest: dest,
                                       destWeightLimit: destWeightLimit)
        
        // assert
        XCTAssertEqual(call.currencyId, currencyId)
        XCTAssertEqual(call.amount, amount)
        XCTAssertEqual(call.dest, dest)
        XCTAssertEqual(call.destWeightLimit, destWeightLimit)
    }
}
