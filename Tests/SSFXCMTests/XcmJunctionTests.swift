import XCTest

@testable import SSFXCM

final class XcmJunctionTests: XCTestCase {
    
    func testIsParachain() {
        // arrange
        let junction = XcmJunction.parachain(0)
        
        // act
        let isParachain = junction.isParachain()
        
        // assert
        XCTAssertTrue(isParachain)
    }
    
    func testEquatable() {
        // arrange
        let junction1 = XcmJunction.generalKey(Data())
        let junction2 = XcmJunction.generalKey(Data())
        
        // assert
        XCTAssertEqual(junction1, junction2)
    }
}

