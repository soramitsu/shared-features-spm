import XCTest

@testable import SSFXCM

final class GeneralKeyV3Tests: XCTestCase {
    
    func testGeneralKeyV3Init() {
        // arrange
        let length: UInt32 = 0
        let data: Data = Data()
        
        // act
        let generalKeyV3 = GeneralKeyV3(lengh: length, data: data)
        
        // assert
        XCTAssertNotNil(generalKeyV3)
        XCTAssertEqual(generalKeyV3.length, length)
        XCTAssertEqual(generalKeyV3.data, data)
    }
    
}
