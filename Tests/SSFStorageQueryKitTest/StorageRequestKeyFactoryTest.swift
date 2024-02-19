import XCTest
import MocksBasket

@testable import SSFStorageQueryKit

final class StorageRequestKeyFactoryTest: XCTestCase {

    private lazy var factory: StorageRequestKeyFactory = {
        StorageRequestKeyFactoryDefault()
    }()

    func testSimple() throws {
        let request = StorageRequestMock(
            parametersType: .simple,
            storagePath: StoragePathMock.custom(moduleName: "1", itemName: "2")
        )
        let key = try factory.createKeyFor(request)
        let expectedKey = "0xd46405367612b4b77db63fd15fba2a198b59801662b521609aa0af6077bc3132"
        XCTAssertEqual(key.toHex(includePrefix: true), expectedKey)
    }
    
    func testEncodable() throws {
        let request = StorageRequestMock(
            parametersType: .encodable(param: "param"),
            storagePath: StoragePathMock.custom(moduleName: "1", itemName: "2")
        )
        let key = try factory.createKeyFor(request)
        let expectedKey = "0xd46405367612b4b77db63fd15fba2a198b59801662b521609aa0af6077bc3132d46405367612b4b77db63fd15fba2a198b59801662b521609aa0af6077bc313271ca01f4b57626ef677c249655abb403"
        XCTAssertEqual(key.toHex(includePrefix: true), expectedKey)
    }
    
    func testNMap() throws {
        let request = StorageRequestMock(
            parametersType: .nMap(params: [
                [NMapKeyParam(value: "key1")],
                [NMapKeyParam(value: "key2")]
            ]),
            storagePath: StoragePathMock.custom(moduleName: "1", itemName: "2")
        )
        let key = try factory.createKeyFor(request)
        let expectedKey = "0xd46405367612b4b77db63fd15fba2a198b59801662b521609aa0af6077bc3132d46405367612b4b77db63fd15fba2a198b59801662b521609aa0af6077bc3132d5b37b02bd238fd0d1a8e63098772c94d46405367612b4b77db63fd15fba2a198b59801662b521609aa0af6077bc313217c5449c7e4c05d8d159d02e12240a72"
        XCTAssertEqual(key.toHex(includePrefix: true), expectedKey)
    }
}
