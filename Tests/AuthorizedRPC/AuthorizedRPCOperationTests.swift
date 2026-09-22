import Foundation
import XCTest
@testable import SSFUtils
import RobinHood

final class AuthorizedRPCOperationTests: XCTestCase {
    func testOperationPropagatesExactGuardAndReturnsRPCResult() throws {
        let engine = OperationEngine()
        let authority = OperationGuard()
        let operation = JSONRPCListOperation<String>(engine: engine, method: "author_submitExtrinsic", parameters: ["signed-fixture"],
            requestOptions: JSONRPCOptions(writeAuthorization: authority))
        operation.main()
        XCTAssertEqual(try XCTUnwrap(operation.result).get(), "ok")
        XCTAssertTrue(engine.options?.writeAuthorization === authority)
        XCTAssertEqual(engine.options?.resendOnReconnect, false)
        XCTAssertTrue(engine.cancelled.isEmpty)
    }

    func testGuardedTimeoutCancelsWriterAndRequiresUnknownOutcomeReconciliation() {
        let engine = OperationEngine()
        engine.respondImmediately = false
        let operation = JSONRPCListOperation<String>(engine: engine, method: "author_submitExtrinsic", timeout: 0,
            requestOptions: JSONRPCOptions(writeAuthorization: OperationGuard()))
        operation.main()
        XCTAssertEqual(engine.cancelled, [77])
        guard case .failure(let error) = operation.result else { return XCTFail("expected timeout") }
        XCTAssertEqual(error as? JSONRPCEngineError, .submissionOutcomeUnknown)
    }

    func testCancellationBeforeStartNeverQueuesRequest() {
        let engine = OperationEngine()
        let operation = JSONRPCListOperation<String>(engine: engine, method: "author_submitExtrinsic",
            requestOptions: JSONRPCOptions(writeAuthorization: OperationGuard()))
        operation.cancel()
        operation.main()
        XCTAssertNil(engine.options)
        XCTAssertNil(operation.result)
        XCTAssertTrue(engine.cancelled.isEmpty)
    }

    func testCancellationDuringRequestIDPublicationCancelsReturnedID() {
        let engine = OperationEngine()
        engine.respondImmediately = false
        let entered = DispatchSemaphore(value: 0), release = DispatchSemaphore(value: 0)
        engine.onCall = { entered.signal(); XCTAssertEqual(release.wait(timeout: .now() + 3), .success) }
        let operation = JSONRPCListOperation<String>(engine: engine, method: "author_submitExtrinsic", timeout: 60,
            requestOptions: JSONRPCOptions(writeAuthorization: OperationGuard()))
        let done = expectation(description: "cancelled operation finishes")
        DispatchQueue.global().async { operation.main(); done.fulfill() }
        XCTAssertEqual(entered.wait(timeout: .now() + 3), .success)
        operation.cancel()
        release.signal()
        wait(for: [done], timeout: 3)
        XCTAssertEqual(engine.cancelled, [77])
        XCTAssertNil(operation.result)
    }

    func testLegacyOperationKeepsItsOriginalOptionsAndTimeoutError() {
        let engine = OperationEngine()
        engine.respondImmediately = false
        let operation = JSONRPCListOperation<String>(engine: engine, method: "system_health", timeout: 0)
        operation.main()
        XCTAssertEqual(engine.options?.resendOnReconnect, true)
        XCTAssertNil(engine.options?.writeAuthorization)
        XCTAssertTrue(engine.cancelled.isEmpty)
        guard case .failure(let error) = operation.result else { return XCTFail("expected timeout") }
        XCTAssertEqual(error as? JSONRPCOperationError, .timeout)
    }
}

private final class OperationGuard: JSONRPCWriteAuthorizing {
    func authorize(_ handoff: () throws -> Void) throws { try handoff() }
}
private final class OperationEngine: JSONRPCEngine {
    var connectionName: String?
    var url: URL?
    var pendingEngineRequests: [JSONRPCRequest] { [] }
    var respondImmediately = true
    var onCall: (() -> Void)?
    private(set) var options: JSONRPCOptions?
    private let lock = NSLock()
    private var cancelledIDs = [UInt16]()
    var cancelled: [UInt16] { lock.lock(); defer { lock.unlock() }; return cancelledIDs }
    func callMethod<P: Codable, T: Decodable>(_ method: String, params: P?, options: JSONRPCOptions,
        completion closure: ((Result<T, Error>) -> Void)?) throws -> UInt16 {
        self.options = options
        onCall?()
        if respondImmediately { closure?(.success(try JSONDecoder().decode(T.self, from: Data("\"ok\"".utf8)))) }
        return 77
    }
    func subscribe<P: Codable, T: Decodable>(_ method: String, params: P?, updateClosure: @escaping (T) -> Void,
        failureClosure: @escaping (Error, Bool) -> Void) throws -> UInt16 { 77 }
    func cancelForIdentifier(_ identifier: UInt16) { lock.lock(); cancelledIDs.append(identifier); lock.unlock() }
    func generateRequestId() -> UInt16 { 77 }
    func addSubscription(_ subscription: JSONRPCSubscribing) {}
    func connectIfNeeded() {}
    func disconnectIfNeeded() {}
    func unsubsribe(_ identifier: UInt16) throws {}
}
