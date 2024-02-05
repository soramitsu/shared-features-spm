import XCTest

@testable import SSFCloudStorage

final class ScryptParametersTests: XCTestCase {
    
    func testScryptParametersInit() {
        // arrange
        let expectedSalt = Data(count: 32)
        let expectedScryptN: UInt32 = 0
        let expectedScryptP: UInt32 = 1
        let expectedScryptR: UInt32 = 2
        
        // act
        do {
            let scryptParameters = try ScryptParameters(salt: expectedSalt,
                                                        scryptN: expectedScryptN,
                                                        scryptP: expectedScryptP,
                                                        scryptR: expectedScryptR)
            
            // assert
            XCTAssertEqual(scryptParameters.salt, expectedSalt)
            XCTAssertEqual(scryptParameters.scryptN, expectedScryptN)
            XCTAssertEqual(scryptParameters.scryptP, expectedScryptP)
            XCTAssertEqual(scryptParameters.scryptR, expectedScryptR)
        } catch {
            XCTFail("Scrypt parameters init test failed with error - \(error)")
        }
    }
    
    func testScryptParametersInitWithError() {
        // arrange
        let expectedSalt = Data(count: 0)
        let expectedScryptN: UInt32 = 0
        let expectedScryptP: UInt32 = 1
        let expectedScryptR: UInt32 = 2
        
        // act
        XCTAssertThrowsError(try ScryptParameters(salt: expectedSalt,
                                                  scryptN: expectedScryptN,
                                                  scryptP: expectedScryptP,
                                                  scryptR: expectedScryptR)) { error in
            // assert
            XCTAssertEqual(error.localizedDescription, ScryptParametersError.invalidSalt.localizedDescription)
        }
    }
    
    func testScryptParametersInitWithScrypts() {
        // arrange
        let expectedSaltLength = 32
        let expectedScryptN: UInt32 = 0
        let expectedScryptP: UInt32 = 1
        let expectedScryptR: UInt32 = 2
        
        // act
        do {
            let scryptParameters = try ScryptParameters(scryptN: expectedScryptN,
                                                        scryptP: expectedScryptP,
                                                        scryptR: expectedScryptR)
            
            // assert
            XCTAssertEqual(scryptParameters.salt.count, expectedSaltLength)
            XCTAssertEqual(scryptParameters.scryptN, expectedScryptN)
            XCTAssertEqual(scryptParameters.scryptP, expectedScryptP)
            XCTAssertEqual(scryptParameters.scryptR, expectedScryptR)
        } catch {
            XCTFail("Scrypt parameters init with scrypts test failed with error - \(error)")
        }
    }
    
    func testScryptParametersInitWithData() {
        // arrange
        let data = Data(count: 44)
        let expectedSalt = data[0..<32]
        
        // act
        do {
            let scryptParameters = try ScryptParameters(data: data)
            
            // assert
            XCTAssertEqual(scryptParameters.salt, expectedSalt)
        } catch {
            XCTFail("Scrypt parameters init with data test failed with error - \(error)")
        }
    }
    
    func testScryptParametersInitWithDataError() {
        // arrange
        let data = Data(count: 32)
        
        // act
        XCTAssertThrowsError(try ScryptParameters(data: data)) { error in
            // assert
            XCTAssertEqual(error.localizedDescription, ScryptParametersError.invalidDataLength.localizedDescription)
        }
    }
    
    func testEncode() {
        // arrange
        let expectedEncodedLength = 44
        let data = Data(repeating: 0, count: expectedEncodedLength)
        
        // act
        do {
            let scryptParameters = try ScryptParameters()
            let encodedData = scryptParameters.encode()
            
            // assert
            XCTAssertEqual(encodedData.count, expectedEncodedLength)
            XCTAssertNotEqual(encodedData, data)
        } catch {
            XCTFail("Encode test failed with error - \(error)")
        }
    }
}
