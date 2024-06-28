import XCTest

@testable import SSFUtils
@testable import Starscream

final class WebSocketEngineTests: XCTestCase {
    
    private let callbackQueue = DispatchQueue(label: "WebSocketEngineTests")

    private var webSocketEngine: WebSocketEngine?
    private var expectation = XCTestExpectation()
    
    enum WebSocketEngineTestsError: Error {
        case wrongEngine
        case trigger
    }

    func testConnected() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 1
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(webSocketEngine.state, .connected)
    }
    
    func testConnectedOnTheSecondAttempt() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 2
        webSocketEngine.didReceive(event: .disconnected("test", 0), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(webSocketEngine.state, .connected)
    }
    
    func testConnectedOnTheSecondLoop() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 3
        webSocketEngine.didReceive(event: .disconnected("disconnect from first url", 0), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .disconnected("disconnect from second url", 1), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 1)
        XCTAssertEqual(webSocketEngine.state, .connected)
    }
    
    func testConnectedOnTheThirdLoop() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 6
        webSocketEngine.didReceive(event: .disconnected("disconnect 1", 0), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .disconnected("disconnect 2", 1), client: strategy.currentConnection)
        webSocketEngine.changeState(.connecting) // imitation failed first loop and trigger for run second loop
        
        webSocketEngine.didReceive(event: .disconnected("disconnect 4", 3), client: strategy.currentConnection)
        webSocketEngine.changeState(.connecting) // imitation failed second loop and trigger for run third loop
        
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 2)
        XCTAssertEqual(webSocketEngine.state, .connected)
    }
    
    func testResendAfterReconnection() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        _ = try webSocketEngine.callMethod(
            "test",
            params: [String]()
        ) {(result: Result<String, Error>) in}
        
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 1)
        webSocketEngine.didReceive(event: .disconnected("disconnected", 0), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 1)
        
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 0)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 1)
        
        webSocketEngine.didReceive(event: .disconnected("desconnected", 1), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 1)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 0)

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 0)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 1)
    }
    
    func testErrorHandling() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self
        
        _ = try webSocketEngine.callMethod(
            "test",
            params: [String]()
        ) {(result: Result<String, Error>) in}

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 0)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 1)
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        
        webSocketEngine.didReceive(event: .error(WebSocketEngineTestsError.trigger), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 0)
        XCTAssertEqual(webSocketEngine.state, .connecting)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
    }
    
    func testCanceledHandling() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self
        
        _ = try webSocketEngine.callMethod(
            "test",
            params: [String]()
        ) {(result: Result<String, Error>) in}

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 0)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 1)
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        
        webSocketEngine.didReceive(event: .cancelled, client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 0)
        XCTAssertEqual(webSocketEngine.state, .connecting)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
    }
    
    func testTimeoutHandling() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self
        
        _ = try webSocketEngine.callMethod(
            "test",
            params: [String]()
        ) {(result: Result<String, Error>) in}

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.pendingRequests.count, 0)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 1)
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        
        webSocketEngine.didReceive(event: .timeout, client: strategy.currentConnection)
        XCTAssertEqual(webSocketEngine.inProgressRequests.count, 0)
        XCTAssertEqual(webSocketEngine.state, .connecting)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
    }
    
    func testWaitingHandling() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 2
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .waiting(error: WebSocketEngineTestsError.trigger), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(webSocketEngine.state, .connecting)
    }
    
    func testReconnectingSuggestedTrue() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 2
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .reconnectSuggested(true), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(webSocketEngine.state, .connecting)
    }
    
    func testReconnectingSuggestedFalse() throws {
        updateExpectation(description: #function)

        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        webSocketEngine.delegate = self

        expectation.expectedFulfillmentCount = 1
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .reconnectSuggested(false), client: strategy.currentConnection)
        
        wait(for: [self.expectation], timeout: 0.25)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(webSocketEngine.state, .connected)
    }
    
    // MARK: - Private methods
    
    private func updateExpectation(description: String) {
        self.expectation = XCTestExpectation(description: description)
    }
    
    private func createEngine(with strategy: ConnectionStrategy) throws -> WebSocketEngine {
        WebSocketEngine(
            connectionName: "WebSocketEngine",
            connectionStrategy: strategy
        )
    }

    private func createConnectionStrategy(for urls: [URL]) throws -> ConnectionStrategy {
        ConnectionStrategyImpl(
            urls: urls,
            callbackQueue: callbackQueue,
            reconnectionStrategy: ReconnectionStrategyProtocolMock()
        )!
    }
}

// MARK: - WebSocketEngineDelegate

extension WebSocketEngineTests: WebSocketEngineDelegate {
    func webSocketDidChangeState(
        engine: SSFUtils.WebSocketEngine,
        from oldState: SSFUtils.WebSocketEngine.State,
        to newState: SSFUtils.WebSocketEngine.State
    ) {
        expectation.fulfill()
    }
}

// MARK: - Fileprivate

fileprivate struct ReconnectionStrategyProtocolMock: ReconnectionStrategyProtocol {
    public func reconnectAfter(attempt: Int) -> TimeInterval? {
        nil
    }
}
