import XCTest
import MocksBasket
import SSFRuntimeCodingService
import SSFUtils
import SSFModels
import BigInt

@testable import SSFStorageQueryKit

final class StorageRequestPerformerTests: XCTestCase {
    
    private var polkadotRuntimeService: RuntimeProviderProtocol!

    override func setUp() async throws {
        try await super.setUp()
        try await buildRuntimeProvider()
    }
    
    // MARK: - performRequest

    func testSimpleRequest() async throws {
        let expectedTimespamp = "1707982452001"
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [["0x21f5afab8d010000", "0x21f5afab8d010000"]]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = StorageRequestMock(
            parametersType: .simple,
            storagePath: StoragePathMock.custom(moduleName: "timestamp", itemName: "now")
        )
        let timestamp: String? = try await performer.performRequest(request)
        
        XCTAssertEqual(expectedTimespamp, timestamp)
    }
    
    func testEncodedRequest() async throws {
        let expectedAccount = try AddressFactory.accountId(
            from: "12zcF9m6QpUaGeJrrKYRGubZuxa9YyuVRTjpXGyVNsCpzspY",
            chainFormat: .sfSubstrate(0)
        )
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [["0x21f5afab8d010000", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4429"]]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = StorageRequestMock(
            parametersType: .encodable(param: expectedAccount),
            storagePath: StoragePathMock.custom(moduleName: "staking", itemName: "bonded")
        )
        let account: AccountId? = try await performer.performRequest(request)
        
        XCTAssertEqual(account, expectedAccount)
    }
    
    func testNMapRequest() async throws {
        let account = try AddressFactory.accountId(
            from: "1zugcag7cJVBtVRnFxv5Qftn7xKAnR6YJ9x4x3XLgGgmNnS",
            chainFormat: .sfSubstrate(0)
        )
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [["0x21f5afab8d010000", "0x02b55b1200"]]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = StorageRequestMock(
            parametersType: .nMap(params: [
                [NMapKeyParam(value: "1353")],
                [NMapKeyParam(value: account)]
            ]),
            storagePath: StoragePathMock.custom(moduleName: "staking", itemName: "erasValidatorPrefs")
        )
        let result: ValidatorPrefs? = try await performer.performRequest(request)
        let extectedResult = ValidatorPrefs(
            commission: BigUInt(stringLiteral: "77000000"),
            blocked: false
        )
        XCTAssertEqual(result, extectedResult)
    }
    
    // MARK: - performRequest AsyncThrowingStream
    
    func testCashOnAll() async throws {
        let expectedTimespamp = "1707982452001"
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [["0x21f5afab8d010000", "0x21f5afab8d010000"]]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = StorageRequestMock(
            parametersType: .simple,
            storagePath: StoragePathMock.custom(moduleName: "timestamp", itemName: "now")
        )
        // fetch remote and save
        let _: String? = try await performer.performRequest(request)
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performRequest(
            request,
            withCacheOptions: [.onAll]
        )
        
        var streamValueCount = 0
        for try await value in stream {
            XCTAssertEqual(value, expectedTimespamp)
            streamValueCount += 1
        }
        XCTAssertEqual(streamValueCount, 2)
    }
    
    func testCashOnCache() async throws {
        let expectedTimespamp = "1707982452001"
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [["0x21f5afab8d010000", "0x21f5afab8d010000"]]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = StorageRequestMock(
            parametersType: .simple,
            storagePath: StoragePathMock.custom(moduleName: "timestamp", itemName: "now")
        )
        // fetch remote and save
        let _: String? = try await performer.performRequest(request)
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performRequest(
            request,
            withCacheOptions: [.onCache]
        )
        
        var streamValueCount = 0
        for try await value in stream {
            XCTAssertEqual(value, expectedTimespamp)
            streamValueCount += 1
        }
        XCTAssertEqual(streamValueCount, 1)
    }
    
    func testCashOnPerform() async throws {
        let expectedTimespamp = "1707982452001"
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [["0x21f5afab8d010000", "0x21f5afab8d010000"]]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = StorageRequestMock(
            parametersType: .simple,
            storagePath: StoragePathMock.custom(moduleName: "timestamp", itemName: "now")
        )
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performRequest(
            request,
            withCacheOptions: [.onPerform]
        )
        
        var streamValueCount = 0
        for try await value in stream {
            XCTAssertEqual(value, expectedTimespamp)
            streamValueCount += 1
        }
        XCTAssertEqual(streamValueCount, 1)
    }

    // MARK: - Private methods
    
    private func buildRuntimeProvider() async throws {
        guard polkadotRuntimeService == nil else {
            return
        }
        polkadotRuntimeService = try await PolkadotRuntimeProvider().buildRuntimeProvider()
    }
    
    private func createConnection(with result: Decodable?) -> JSONRPCEngine {
        let mock = JSONRPCEngineMock()
        mock.completionResult = result
        return mock
    }
}

struct ValidatorPrefs: Codable, Equatable {
    @StringCodable var commission: BigUInt
    let blocked: Bool
}

