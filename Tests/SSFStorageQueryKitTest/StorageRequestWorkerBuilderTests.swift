import XCTest
import MocksBasket
import SSFModels

@testable import SSFStorageQueryKit

final class StorageRequestWorkerBuilderTests: XCTestCase {

    func testSimple() throws {
        let builder = StorageRequestWorkerBuilderDefault<String>()
        let simpleWorker = builder.buildWorker(
            runtimeService: RuntimeCodingServiceProtocolMock(),
            connection: JSONRPCEngineMock(),
            storageRequestFactory: AsyncStorageRequestDefault(),
            request: StorageRequestMock(
                parametersType: .simple,
                storagePath: StorageCodingPath.account
            )
        )
        XCTAssertTrue(simpleWorker is SimpleStorageRequestWorker<String>)
    }
    
    func testNMap() throws {
        let builder = StorageRequestWorkerBuilderDefault<String>()
        let simpleWorker = builder.buildWorker(
            runtimeService: RuntimeCodingServiceProtocolMock(),
            connection: JSONRPCEngineMock(),
            storageRequestFactory: AsyncStorageRequestDefault(),
            request: StorageRequestMock(
                parametersType: .nMap(params: []),
                storagePath: StorageCodingPath.account
            )
        )
        XCTAssertTrue(simpleWorker is NMapStorageRequestWorker<String>)
    }
    
    func testEnocodable() throws {
        let builder = StorageRequestWorkerBuilderDefault<String>()
        let simpleWorker = builder.buildWorker(
            runtimeService: RuntimeCodingServiceProtocolMock(),
            connection: JSONRPCEngineMock(),
            storageRequestFactory: AsyncStorageRequestDefault(),
            request: StorageRequestMock(
                parametersType: .encodable(param: ""),
                storagePath: StorageCodingPath.account
            )
        )
        XCTAssertTrue(simpleWorker is EncodableStorageRequestWorker<String>)
    }
}
