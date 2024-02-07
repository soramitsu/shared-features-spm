import XCTest
import SSFModels

@testable import SSFXCM

final class XcmJunctionNetworkIdTests: XCTestCase {

    func testFromEcosystem() {
        // arrange
        let ecosystem: ChainEcosystem = .ethereum
        
        // act
        let id = XcmJunctionNetworkId.from(ecosystem: ecosystem)
        
        // assert
        XCTAssertEqual(id, .ethereum)
    }
    
}
