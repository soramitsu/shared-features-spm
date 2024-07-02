import XCTest

@testable import SSFUtils
@testable import Starscream

final class WebSocketEngineTests: XCTestCase {
    
    private let callbackQueue = DispatchQueue(label: "WebSocketEngineTests")

    private var webSocketEngine: WebSocketEngine?
    
    enum WebSocketEngineTestsError: Error {
        case wrongEngine
        case trigger
    }

    func testConnected() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.state, .connected)
    }
    
    func testConnectedOnTheSecondAttempt() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .disconnected("test", 0), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.state, .connected)
    }
    
    func testConnectedOnTheSecondLoop() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .disconnected("disconnect from first url", 0), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .disconnected("disconnect from second url", 1), client: strategy.currentConnection)
        strategy.didTrigger(scheduler: SchedulerMock())
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 1)
        XCTAssertEqual(strategy.state, .connected)
    }
    
    func testConnectedOnTheThirdLoop() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .disconnected("disconnect 1", 0), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .disconnected("disconnect 2", 1), client: strategy.currentConnection)
        strategy.didTrigger(scheduler: SchedulerMock())
        
        webSocketEngine.didReceive(event: .disconnected("disconnect 3", 2), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .disconnected("disconnect 4", 3), client: strategy.currentConnection)
        strategy.didTrigger(scheduler: SchedulerMock())
        
        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 2)
        XCTAssertEqual(strategy.state, .connected)
    }
    
    func testResendAfterReconnection() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

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
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        
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
        XCTAssertEqual(strategy.state, .connecting)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
    }
    
    func testCanceledHandling() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        
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
        XCTAssertEqual(strategy.state, .connecting)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
    }
    
    func testTimeoutHandling() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine
        
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
        XCTAssertEqual(strategy.state, .connecting)
        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
    }
    
    func testWaitingHandling() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .waiting(error: WebSocketEngineTestsError.trigger), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.state, .connecting)
    }
    
    func testReconnectingSuggestedTrue() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .reconnectSuggested(true), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io/1"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.state, .connecting)
    }
    
    func testReconnectingSuggestedFalse() throws {
        let strategy = try createConnectionStrategy(for: [
            URL(string: "https://wiki.fearlesswallet.io")!,
            URL(string: "https://wiki.fearlesswallet.io/1")!
        ])
        let webSocketEngine = try createEngine(with: strategy)
        self.webSocketEngine = webSocketEngine

        webSocketEngine.didReceive(event: .connected([:]), client: strategy.currentConnection)
        webSocketEngine.didReceive(event: .reconnectSuggested(false), client: strategy.currentConnection)

        XCTAssertEqual(strategy.currentUrl, URL(string: "https://wiki.fearlesswallet.io"))
        XCTAssertEqual(strategy.currentLoop, 0)
        XCTAssertEqual(strategy.state, .connected)
    }
    
    // MARK: - Private methods
    
    private func createEngine(with strategy: ConnectionStrategy) throws -> WebSocketEngine {
        WebSocketEngine(
            connectionName: "WebSocketEngine",
            connectionStrategy: strategy
        )
    }

    private func createConnectionStrategy(for urls: [URL]) throws -> ConnectionStrategyImpl {
        ConnectionStrategyImpl(
            urls: urls,
            callbackQueue: callbackQueue,
            reconnectionStrategy: ReconnectionStrategyProtocolMock()
        )!
    }
}

// MARK: - Fileprivate

fileprivate struct ReconnectionStrategyProtocolMock: ReconnectionStrategyProtocol {
    public func reconnectAfter(attempt: Int) -> TimeInterval? {
        nil
    }
}

fileprivate class SchedulerMock: SchedulerProtocol {
    func notifyAfter(_ seconds: TimeInterval) {}
    func cancel() {}
}
