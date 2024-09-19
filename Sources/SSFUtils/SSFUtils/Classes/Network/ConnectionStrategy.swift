import Foundation
import Starscream

public protocol ConnectionStrategy {
    var webSocketEngine: WebSocketEngine? { get }
    var currentConnection: WebSocketConnectionProtocol { get }
    var callbackQueue: DispatchQueue { get }
    var currentUrl: URL { get }
    var currentLoop: Int { get }
    var state: WebSocketEngine.State { get }

    func set(webSocketEngine: WebSocketEngine)
    func changeState(_ newState: WebSocketEngine.State)

    func disconnect()
    func cancelReconnectionSchedule()

    func canReconnect() -> Bool
    func shouldRunInNextLoop() -> Bool
}

public final class ConnectionStrategyImpl: ConnectionStrategy {
    // MARK: - Public properties

    public weak var webSocketEngine: WebSocketEngine?
    public var currentConnection: WebSocketConnectionProtocol
    public var state: WebSocketEngine.State
    public var callbackQueue: DispatchQueue
    public var currentUrl: URL
    public var currentLoop: Int = 0

    // MARK: - Private properties

    private let urls: [URL]
    private let timeout: TimeInterval
    private let reconnectionStrategy: ReconnectionStrategyProtocol?
    private let logger: SDKLoggerProtocol?
    private lazy var reconnectionScheduler: SchedulerProtocol = Scheduler(
        with: self,
        callbackQueue: callbackQueue
    )

    // MARK: - Constuctor

    public init?(
        urls: [URL],
        callbackQueue: DispatchQueue,
        timeout: TimeInterval = 10.0,
        autoconnect: Bool = true,
        reconnectionStrategy: ReconnectionStrategyProtocol? = ExponentialReconnection(),
        logger: SDKLoggerProtocol? = nil
    ) {
        self.urls = urls
        self.callbackQueue = callbackQueue
        self.timeout = timeout
        self.reconnectionStrategy = reconnectionStrategy
        self.logger = logger

        guard let url = urls.first else {
            return nil
        }
        currentUrl = url
        let request = URLRequest(url: url, timeoutInterval: timeout)
        let engine = WSEngine(transport: TCPTransport(), certPinner: FoundationSecurity())
        let connection = WebSocket(request: request, engine: engine)
        connection.callbackQueue = callbackQueue
        currentConnection = connection

        if autoconnect {
            state = .connecting
            currentConnection.connect()
        } else {
            state = .notConnected
        }
    }

    // MARK: - Public methods

    public func set(webSocketEngine: WebSocketEngine) {
        self.webSocketEngine = webSocketEngine
        currentConnection.delegate = webSocketEngine
    }

    public func changeState(_ newState: WebSocketEngine.State) {
        state = newState
        updateConnection()
    }

    public func disconnect() {
        currentConnection.disconnect()
    }

    public func cancelReconnectionSchedule() {
        reconnectionScheduler.cancel()
    }

    public func canReconnect() -> Bool {
        reconnectionStrategy != nil
    }

    public func shouldRunInNextLoop() -> Bool {
        let currentUrlIndex = urls.firstIndex(of: currentUrl) ?? 0
        let nextIndex = currentUrlIndex + 1
        return !urls.indices.contains(nextIndex)
    }

    // MARK: - Private methods

    private func updateConnection() {
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

    private func handleConnectingState() {
        let currentUrlIndex = urls.firstIndex(of: currentUrl) ?? 0
        let nextIndex = currentUrlIndex + 1
        let nextUrl = urls.indices.contains(nextIndex) ? urls[nextIndex] : urls.first
        guard let nextUrl else {
            return
        }
        updateConnection(with: nextUrl)
        currentConnection.connect()
    }

    private func handleWaitingNewLoopState() {
        currentLoop += 1
        if currentLoop > 5 {
            currentLoop = 0
        }

        scheduleReconnection()
    }

    private func scheduleReconnection() {
        guard let reconnectionStrategy,
              let nextDelay = reconnectionStrategy.reconnectAfter(attempt: currentLoop) else
        {
            return
        }
        reconnectionScheduler.cancel()
        reconnectionScheduler.notifyAfter(nextDelay)
    }

    private func updateConnection(
        with url: URL
    ) {
        guard currentUrl != url else {
            return
        }
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
    public func didTrigger(scheduler _: any SchedulerProtocol) {
        state = .connecting
        updateConnection()
    }
}
