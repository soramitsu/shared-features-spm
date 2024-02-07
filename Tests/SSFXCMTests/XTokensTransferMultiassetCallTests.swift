import XCTest
import SSFModels
import BigInt

@testable import SSFXCM

final class XTokensTransferMultiassetCallTests: XCTestCase {
        
    func testXTokensTransferMultiassetCallInit() {
        // arrange
        let asset: XcmVersionedMultiAsset = .V1(.init(multilocation: .init(parents: 0,
                                                                           interior: .init(items: [.onlyChild])),
                                                      amount: BigUInt()))
        let dest: XcmVersionedMultiLocation = .V1(.init(parents: 0, interior: .init(items: [.onlyChild])))
        let destWeightLimit: XcmWeightLimit = .unlimited
        let destWeightIsPrimitive: Bool = true
        let destWeight: BigUInt = BigUInt()
        
        // act
        let call = XTokensTransferMultiassetCall(asset: asset,
                                                 dest: dest,
                                                 destWeightLimit: destWeightLimit,
                                                 destWeightIsPrimitive: destWeightIsPrimitive,
                                                 destWeight: destWeight)
        
        // assert
        XCTAssertEqual(call.asset, asset)
        XCTAssertEqual(call.dest, dest)
        XCTAssertEqual(call.destWeightLimit, destWeightLimit)
        XCTAssertEqual(call.destWeightIsPrimitive, destWeightIsPrimitive)
        XCTAssertEqual(call.destWeight, destWeight)
    }
    
}
