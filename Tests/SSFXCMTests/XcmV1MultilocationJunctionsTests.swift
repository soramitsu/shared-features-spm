import XCTest

@testable import SSFXCM

final class XcmV1MultilocationJunctionsTests: XCTestCase {
    
    func testXcmV1MultilocationJunctionsInit() {
        // arrange
        let items: [XcmJunction] = [.onlyChild]
        
        // act
        let junctions = XcmV1MultilocationJunctions(items: items)
        
        // assert
        XCTAssertEqual(junctions.items, items)
    }
}
