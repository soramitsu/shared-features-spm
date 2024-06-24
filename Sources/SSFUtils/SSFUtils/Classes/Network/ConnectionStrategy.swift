import Foundation
import Starscream

public protocol ConnectionStrategy {
    var currentConnection: WebSocketConnectionProtocol { get }
    var callbackQueue: DispatchQueue { get }
    
    func updateConnection(
        for state: WebSocketEngine.State,
        delegate: WebSocketDelegate?
    )
    
    func disconnect()
    func cancelReconectionShedule()
    
    func canReconnect() -> Bool
    func shouldRunInNextLoop() -> Bool
}

public final class ConnectionStrategyImpl: ConnectionStrategy {
    
    // MARK: - Public properties
    
    private(set) public var currentConnection: WebSocketConnectionProtocol
    private(set) public var callbackQueue: DispatchQueue
    
    // MARK: - Private properties
    
    private let urls: [URL]
    private let timeout: TimeInterval
    private let reconnectionStrategy: ReconnectionStrategyProtocol?
    private let logger: SDKLoggerProtocol?
    private lazy var reconnectionScheduler: SchedulerProtocol = {
        Scheduler(with: self, callbackQueue: callbackQueue)
    }()
    
    // MARK: - State
    
    private var currentUrl: URL
    private var currentLoop: Int = 0
    
    // MARK: - Constuctor
    
    public init(
        urls: [URL],
        callbackQueue: DispatchQueue,
        timeout: TimeInterval = 10.0,
        reconnectionStrategy: ReconnectionStrategyProtocol? = ExponentialReconnection(),
        logger: SDKLoggerProtocol?
    ) throws {
        self.urls = urls
        self.callbackQueue = callbackQueue
        self.timeout = timeout
        self.reconnectionStrategy = reconnectionStrategy
        self.logger = logger
        
        guard let firstUrl = urls.first else {
            throw WebSocketEngineError.emptyUrls
        }
        self.currentUrl = firstUrl
        let request = URLRequest(url: firstUrl, timeoutInterval: timeout)
        let engine = WSEngine(transport: TCPTransport(), certPinner: FoundationSecurity())
        let connection = WebSocket(request: request, engine: engine)
        currentConnection = connection
    }
    
    // MARK: - Public methods
    
    public func updateConnection(
        for state: WebSocketEngine.State,
        delegate: WebSocketDelegate?
    ) {
        logger?.debug("\(state)")
        switch state {
        case .notConnected:
            logger?.debug("Did start connecting to socket")
        case .connecting:
            logger?.debug("Start connecting with attempt: \(currentLoop)")
            handleConnectingState()
        case .waitingNewLoop:
            handleWaitingNewLoopState()
        case .connected:
            logger?.debug("connection established")
        case .notReachable:
            break
        }
    }
    
    public func disconnect() {
        currentConnection.disconnect()
    }
    
    public func cancelReconectionShedule() {
        reconnectionScheduler.cancel()
    }
    
    public func canReconnect() -> Bool {
        reconnectionStrategy != nil
    }
    
    public func shouldRunInNextLoop() -> Bool {
        let currentUrlIndex = urls.firstIndex(of: currentUrl) ?? 0
        let nextIndex = currentUrlIndex + 1
        return nextIndex > urls.count
    }
    
    // MARK: - Private methods
    
    private func handleConnectingState() {
        let currentUrlIndex = urls.firstIndex(of: currentUrl) ?? 0
        let nextIndex = currentUrlIndex + 1
        let nextUrl = urls.indices.contains(nextIndex) ? urls[nextIndex] : nil
        guard let nextUrl else { return }
        updateConnection(with: nextUrl)
        currentConnection.connect()
    }
    
    private func handleWaitingNewLoopState() {
        currentLoop += 1
        sheduleReconnection()
    }
    
    private func sheduleReconnection() {
        guard
            let reconnectionStrategy,
            let nextDelay = reconnectionStrategy.reconnectAfter(attempt: currentLoop)
        else {
            return
        }
        reconnectionScheduler.notifyAfter(nextDelay)
    }

    private func updateConnection(
        with url: URL
    ) {
        let request = URLRequest(url: url, timeoutInterval: timeout)
        let engine = WSEngine(transport: TCPTransport(), certPinner: FoundationSecurity())
        let connection = WebSocket(request: request, engine: engine)
        connection.callbackQueue = callbackQueue
        currentConnection = connection
        currentUrl = url
    }
}

// MARK: - SchedulerDelegate

extension ConnectionStrategyImpl: SchedulerDelegate {
    public func didTrigger(scheduler: any SchedulerProtocol) {
        guard let firstUrl = urls.first else {
            return
        }
        updateConnection(with: firstUrl)
    }
}
