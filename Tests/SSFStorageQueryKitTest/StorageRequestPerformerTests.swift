import XCTest
import MocksBasket
import SSFRuntimeCodingService
import SSFUtils
import SSFModels
import BigInt
import SSFCrypto

@testable import SSFStorageQueryKit

final class StorageRequestPerformerTests: XCTestCase {
    
    private var polkadotRuntimeService: RuntimeProviderProtocol!

    override func setUp() async throws {
        try await super.setUp()
        try await buildRuntimeProvider()
    }
    
    // MARK: - performSingleRequest

    func testSimpleSingleRequest() async throws {
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
        let timestamp: String? = try await performer.performSingle(request)
        
        XCTAssertEqual(expectedTimespamp, timestamp)
    }
    
    func testEncodedSingleRequest() async throws {
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
        let account: AccountId? = try await performer.performSingle(request)
        
        XCTAssertEqual(account, expectedAccount)
    }
    
    func testNMapSingleRequest() async throws {
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
        let result: ValidatorPrefs? = try await performer.performSingle(request)
        let extectedResult = ValidatorPrefs(
            commission: BigUInt(stringLiteral: "77000000"),
            blocked: false
        )
        XCTAssertEqual(result, extectedResult)
    }
    
    // MARK: - performSingleRequest AsyncThrowingStream
    
    func testCashOnAllSingle() async throws {
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
        let _: String? = try await performer.performSingle(request)
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performSingle(
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
    
    func testCashWithAllOptionsByManualSingle() async throws {
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
        let _: String? = try await performer.performSingle(request)
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performSingle(
            request,
            withCacheOptions: [.onPerform, .onCache]
        )
        
        var streamValueCount = 0
        for try await value in stream {
            XCTAssertEqual(value, expectedTimespamp)
            streamValueCount += 1
        }
        XCTAssertEqual(streamValueCount, 2)
    }
    
    func testCashOnCacheSingle() async throws {
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
        let _: String? = try await performer.performSingle(request)
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performSingle(
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
    
    func testCashOnPerformSingle() async throws {
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
        
        let stream: AsyncThrowingStream<String?, Error> = await performer.performSingle(
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
    
    // MARK: - performMultiple
    
    func testEncodedMultipleRequest() async throws {
        let account1 = try Data(hexStringSSF: "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4420")
        let account2 = try Data(hexStringSSF: "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4411")
        let account3 = try Data(hexStringSSF: "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4412")
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [
                ["0x21f5afab8d010000", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4420"],
                ["0x21f5afab8d010001", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4411"],
                ["0x21f5afab8d010002", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4412"]
            ]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = MultipleStorageRequstMock(
            parametersType: .multipleEncodable(params: [account1, account2, account3]),
            storagePath: StoragePathMock.custom(moduleName: "staking", itemName: "bonded")
        )
        let accounts: [AccountId?] = try await performer.performMultiple(request)
        
        XCTAssertEqual(accounts, [account1, account2, account3])
    }
    
    func testNMapMultipleRequest() async throws {
        let account = try AddressFactory.accountId(
            from: "1zugcag7cJVBtVRnFxv5Qftn7xKAnR6YJ9x4x3XLgGgmNnS",
            chainFormat: .sfSubstrate(0)
        )
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [
                ["0x21f5afab8d010000", "0x02b55b1200"],
                ["0x21f5afab8d010001", "0x02b55b1300"],
                ["0x21f5afab8d010002", "0x02b55b1400"]
            ]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = MultipleStorageRequstMock(
            parametersType: .multipleNMap(params: [
                [NMapKeyParam(value: "1353"), NMapKeyParam(value: "1353"), NMapKeyParam(value: "1353")],
                [NMapKeyParam(value: account), NMapKeyParam(value: account), NMapKeyParam(value: account)]
            ]),
            storagePath: StoragePathMock.custom(moduleName: "staking", itemName: "erasValidatorPrefs")
        )
        let result: [ValidatorPrefs?] = try await performer.performMultiple(request)
        let extectedResult1 = ValidatorPrefs(
            commission: BigUInt(stringLiteral: "77000000"),
            blocked: false
        )
        let extectedResult2 = ValidatorPrefs(
            commission: BigUInt(stringLiteral: "81194304"),
            blocked: false
        )
        let extectedResult3 = ValidatorPrefs(
            commission: BigUInt(stringLiteral: "85388608"),
            blocked: false
        )
        XCTAssertEqual(result, [extectedResult1, extectedResult2, extectedResult3])
    }
    
    // MARK: - performMultiple AsyncThrowingStream
    
    func testEncodedMultipleRequestCache() async throws {
        let account1 = try Data(hexStringSSF: "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4420")
        let account2 = try Data(hexStringSSF: "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4411")
        let account3 = try Data(hexStringSSF: "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4412")
        let storageUpdate = StorageUpdate(
            blockHash: nil,
            changes: [
                ["0x21f5afab8d010000", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4420"],
                ["0x21f5afab8d010001", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4411"],
                ["0x21f5afab8d010002", "0x582bdd02e8b7e3a97da353f92954db770676e7f07eddf2d08cb9f2430aaf4412"]
            ]// key, value
        )
        let performer = StorageRequestPerformerDefault(
            runtimeService: polkadotRuntimeService,
            connection: createConnection(with: [storageUpdate])
        )
        let request = MultipleStorageRequstMock(
            parametersType: .multipleEncodable(params: [account1, account2, account3]),
            storagePath: StoragePathMock.custom(moduleName: "staking", itemName: "bonded")
        )
        let _: [AccountId?] = try await performer.performMultiple(request)
        let stream: AsyncThrowingStream<[AccountId?], Error> = await performer.performMultiple(request, withCacheOptions: .onAll)
        
        var streamValueCount = 0
        for try await value in stream {
            XCTAssertEqual(value, [account1, account2, account3])
            streamValueCount += 1
        }
        XCTAssertEqual(streamValueCount, 2)
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

// TODO: - Transfer this model to staking package
struct ValidatorPrefs: Codable, Equatable {
    @StringCodable var commission: BigUInt
    let blocked: Bool
}

