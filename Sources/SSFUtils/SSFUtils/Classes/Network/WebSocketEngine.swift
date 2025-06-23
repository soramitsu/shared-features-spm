import Foundation
import Starscream
import Combine
import Network

public protocol WebSocketConnectionProtocol: WebSocketClient {
    var callbackQueue: DispatchQueue { get }
    var delegate: WebSocketDelegate? { get set }
    func forceDisconnect()
}

extension WebSocket: WebSocketConnectionProtocol {
    public func forceDisconnect() {
        disconnect(closeCode: CloseCode.goingAway.rawValue)
    }
}

public protocol WebSocketEngineDelegate: AnyObject {
    func webSocketDidChangeState(
        engine: WebSocketEngine,
        from oldState: WebSocketEngine.State,
        to newState: WebSocketEngine.State
    )
}

public final class WebSocketEngine {
    public static let sharedProcessingQueue = DispatchQueue(label: "io.novasama.ws.processing")

    public enum State {
        case notConnected
        case connecting(attempt: Int)
        case connected

        var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }
    }

    // MARK: - Properties

    public var connection: WebSocketConnectionProtocol
    public let version: String
    public let logger: SDKLoggerProtocol?
    public let completionQueue: DispatchQueue
    public let pingInterval: TimeInterval

    public private(set) var state: State = .notConnected {
        didSet {
            if let delegate = delegate {
                let oldState = oldValue
                let newState = state
                delegate.webSocketDidChangeState(engine: self, from: oldState, to: newState)
            }
        }
    }

    private let mutex = NSLock()
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let reconnectionStrategy: ReconnectionStrategyProtocol?

    private(set) lazy var reconnectionScheduler: SchedulerProtocol = {
        Scheduler(with: self, callbackQueue: connection.callbackQueue)
    }()

    private(set) lazy var pingScheduler: SchedulerProtocol = {
        Scheduler(with: self, callbackQueue: connection.callbackQueue)
    }()

    private(set) var pendingRequests: [JSONRPCRequest] = []
    private(set) var inProgressRequests: [UInt16: JSONRPCRequest] = [:]
    private(set) var subscriptions: [UInt16: JSONRPCSubscribing] = [:]
    private(set) var unknownResponsesByRemoteId: [String: [Data]] = [:]

    public weak var delegate: WebSocketEngineDelegate?
    public var url: URL?
    public var connectionName: String?
    private(set) var engine: WSEngine

    private var isExplicitlyDisconnected = false
    private var networkMonitor: NWPathMonitor?
    private var networkMonitorQueue = DispatchQueue(label: "io.novasama.network.monitor")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        connectionName: String?,
        url: URL,
        reconnectionStrategy: ReconnectionStrategyProtocol? = ExponentialReconnection(),
        version: String = "2.0",
        processingQueue: DispatchQueue? = nil,
        autoconnect: Bool = true,
        connectionTimeout: TimeInterval = 10.0,
        pingInterval: TimeInterval = 30,
        logger: SDKLoggerProtocol? = nil
    ) {
        self.connectionName = connectionName
        self.url = url
        self.version = version
        self.logger = logger
        self.reconnectionStrategy = reconnectionStrategy
        self.completionQueue = processingQueue ?? Self.sharedProcessingQueue
        self.pingInterval = pingInterval

        let request = URLRequest(url: url, timeoutInterval: connectionTimeout)
        self.engine = WSEngine(transport: TCPTransport(), certPinner: FoundationSecurity())
        let connection = WebSocket(request: request, engine: engine)
        self.connection = connection

        connection.delegate = self
        connection.callbackQueue = processingQueue ?? Self.sharedProcessingQueue

        setupNetworkMonitoring()

        if autoconnect {
            connectIfNeeded()
        }
    }

    deinit {
        networkMonitor?.cancel()
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Public Methods

    public func connectIfNeeded() {
        mutex.lock()
        defer { mutex.unlock() }

        switch state {
        case .notConnected:
            isExplicitlyDisconnected = false
            startConnecting(0)
            logger?.debug("Did start connecting to socket")
        default:
            logger?.debug("Already connecting or connected to socket")
        }
    }

    public func disconnectIfNeeded() {
        mutex.lock()
        defer { mutex.unlock() }

        isExplicitlyDisconnected = true

        switch state {
        case .connected:
            state = .notConnected
            let cancelledRequests = resetInProgress()
            connection.disconnect(closeCode: CloseCode.goingAway.rawValue)
            notify(requests: cancelledRequests, error: JSONRPCEngineError.clientCancelled)
            pingScheduler.cancel()
            logger?.debug("Did start disconnect from socket")

        case .connecting:
            state = .notConnected
            connection.disconnect()
            logger?.debug("Cancel socket connection")

        default:
            logger?.debug("Already disconnected from socket")
        }
    }

    public func forceReconnect() {
        mutex.lock()
        defer { mutex.unlock() }

        isExplicitlyDisconnected = false
        reconnectImmediately()
    }

    public func unsubsribe(_ identifier: UInt16) throws {
        mutex.lock()
        defer { mutex.unlock() }

        try processUnsubscription(identifier)
    }

    // MARK: - Network Monitoring

    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkPathUpdate(path)
        }
        networkMonitor?.start(queue: networkMonitorQueue)
    }

    private func handleNetworkPathUpdate(_ path: NWPath) {
        mutex.lock()
        defer { mutex.unlock() }

        guard !isExplicitlyDisconnected else { return }

        if path.status == .satisfied {
            logger?.debug("Network became reachable")
            if !state.isConnected {
                reconnectImmediately()
            }
        } else {
            logger?.debug("Network became unreachable")
            let cancelledRequests = resetInProgress()
            pingScheduler.cancel()
            connection.forceDisconnect()
            notify(requests: cancelledRequests, error: JSONRPCEngineError.networkNotReachable)
            state = .notConnected
        }
    }

    // MARK: - Connection Management

    private func reconnectImmediately() {
        logger?.debug("Attempting immediate reconnect")

        let cancelledRequests = resetInProgress()
        pingScheduler.cancel()
        connection.forceDisconnect()

        notify(requests: cancelledRequests, error: JSONRPCEngineError.clientCancelled)

        startConnecting(0)
    }

    private func startConnecting(_ attempt: Int) {
        logger?.debug("Start connecting with attempt: \(attempt)")
        state = .connecting(attempt: attempt)
        connection.connect()
    }

    private let maxReconnectionAttempts = 5

    private func attemptReconnection(_ attempt: Int, error: Error? = nil) {
        if attempt > maxReconnectionAttempts {
            logger?.error("Max reconnection attempts reached")
            state = .notConnected
            let requests = pendingRequests
            pendingRequests = []
            let requestError = error ?? JSONRPCEngineError.connectionFailed
            requests.forEach { $0.responseHandler?.handle(error: requestError) }
            return
        }

        if let reconnectionStrategy = reconnectionStrategy,
           let nextDelay = reconnectionStrategy.reconnectAfter(attempt: attempt - 1) {
            logger?.debug("Will attempt reconnect #\(attempt) after \(nextDelay) seconds")
            reconnectionScheduler.notifyAfter(nextDelay)
        } else {
            state = .notConnected
            let requests = pendingRequests
            pendingRequests = []
            let requestError = error ?? JSONRPCEngineError.connectionFailed
            requests.forEach { $0.responseHandler?.handle(error: requestError) }
        }
    }

    // MARK: - Request Handling

    private func updateConnectionForRequest(_ request: JSONRPCRequest) {
        switch state {
        case .connected:
            send(request: request)
        case .connecting:
            pendingRequests.append(request)
        case .notConnected:
            pendingRequests.append(request)
            startConnecting(0)
        }
    }

    private func send(request: JSONRPCRequest) {
        inProgressRequests[request.requestId] = request
        connection.write(stringData: request.data, completion: nil)
    }

    private func sendAllPendingRequests() {
        let currentPendings = pendingRequests
        pendingRequests = []

        for pending in currentPendings {
            logger?.debug("Sending request with id: \(pending.requestId)")
            logger?.debug("\(String(data: pending.data, encoding: .utf8)!)")
            send(request: pending)
        }
    }

    private func resetInProgress() -> [JSONRPCRequest] {
        let idempotentRequests: [JSONRPCRequest] = inProgressRequests.compactMap {
            $1.options.resendOnReconnect ? $1 : nil
        }

        let notifiableRequests = inProgressRequests.compactMap {
            !$1.options.resendOnReconnect && $1.responseHandler != nil ? $1 : nil
        }

        pendingRequests.append(contentsOf: idempotentRequests)
        inProgressRequests = [:]

        rescheduleActiveSubscriptions()

        return notifiableRequests
    }

    private func rescheduleActiveSubscriptions() {
        let activeSubscriptions = subscriptions.compactMap {
            $1.remoteId != nil ? $1 : nil
        }

        for subscription in activeSubscriptions {
            subscription.remoteId = nil
        }

        let subscriptionRequests: [JSONRPCRequest] = activeSubscriptions.enumerated().map {
            JSONRPCRequest(
                requestId: $1.requestId,
                data: $1.requestData,
                options: $1.requestOptions,
                responseHandler: nil
            )
        }

        pendingRequests.append(contentsOf: subscriptionRequests)
    }

    // MARK: - Response Processing

    private func process(data: Data) {
        do {
            let response = try jsonDecoder.decode(JSONRPCBasicData.self, from: data)

            if let identifier = response.identifier {
                if let error = response.error {
                    completeRequestForRemoteId(identifier, error: error)
                } else {
                    completeRequestForRemoteId(identifier, data: data)
                }
            } else {
                try processSubscriptionUpdate(data)
            }
        } catch {
            if let stringData = String(data: data, encoding: .utf8) {
                logger?.error("Can't parse data: \(stringData)")
            } else {
                logger?.error("Can't parse data")
            }
        }
    }

    public func addSubscription(_ subscription: JSONRPCSubscribing) {
        subscriptions[subscription.requestId] = subscription
    }

    private func completeRequestForRemoteId(_ identifier: UInt16, data: Data) {
        if let request = inProgressRequests.removeValue(forKey: identifier) {
            notify(request: request, data: data)
        }

        if subscriptions[identifier] != nil {
            processSubscriptionResponse(identifier, data: data)
        }
    }

    private func processSubscriptionResponse(_ identifier: UInt16, data: Data) {
        do {
            let response = try jsonDecoder.decode(JSONRPCData<String>.self, from: data)
            subscriptions[identifier]?.remoteId = response.result

            if let postponed = unknownResponsesByRemoteId[response.result] {
                for data in postponed {
                    try processSubscriptionUpdate(data)
                }
                unknownResponsesByRemoteId[response.result] = nil
            }

            logger?.debug("Did receive subscription id: \(response.result)")
        } catch {
            processSubscriptionError(identifier, error: error, shouldUnsubscribe: true)

            if let responseString = String(data: data, encoding: .utf8) {
                logger?.error("Did fail to parse subscription data: \(responseString)")
            } else {
                logger?.error("Did fail to parse subscription data")
            }
        }
    }

    private func processSubscriptionUpdate(_ data: Data) throws {
        let basicResponse = try jsonDecoder.decode(
            JSONRPCSubscriptionBasicUpdate.self,
            from: data
        )
        let remoteId = basicResponse.params.subscription

        if let (_, subscription) = subscriptions.first(where: { $1.remoteId == remoteId }) {
            logger?.debug("Did receive update for subscription: \(remoteId)")
            completionQueue.async {
                try? subscription.handle(data: data)
            }
        } else {
            logger?.warning("No handler for subscription: \(remoteId)")
            if unknownResponsesByRemoteId[remoteId] == nil {
                unknownResponsesByRemoteId[remoteId] = []
            }
            unknownResponsesByRemoteId[remoteId]?.append(data)
        }
    }

    private func completeRequestForRemoteId(_ identifier: UInt16, error: Error) {
        if let request = inProgressRequests.removeValue(forKey: identifier) {
            notify(requests: [request], error: error)
        }

        if subscriptions[identifier] != nil {
            processSubscriptionError(identifier, error: error, shouldUnsubscribe: true)
        }
    }

    private func processSubscriptionError(_ identifier: UInt16, error: Error, shouldUnsubscribe: Bool) {
        if let subscription = subscriptions[identifier] {
            if shouldUnsubscribe {
                subscriptions.removeValue(forKey: identifier)
            }

            connection.callbackQueue.async {
                subscription.handle(error: error, unsubscribed: shouldUnsubscribe)
            }
        }
    }

    private func processUnsubscription(_ identifier: UInt16) throws {
        guard let subscription = subscriptions[identifier] else { return }

        let requestInfo = try jsonDecoder.decode(
            JSONRPCInfo<[[Data]]>.self,
            from: subscription.requestData
        )

        _ = try callMethod(
            RPCMethod.stateUnsubscribe,
            params: requestInfo.params,
            options: JSONRPCOptions(resendOnReconnect: false)
        ) { [weak self] (result: Result<Data, Error>) in
            guard case .success = result else { return }
            self?.subscriptions.removeValue(forKey: identifier)
        }
    }

    // MARK: - Ping Management

    private func schedulePingIfNeeded() {
        guard pingInterval > 0.0, case .connected = state else {
            return
        }

        logger?.debug("Schedule socket ping")
        pingScheduler.notifyAfter(pingInterval)
    }

    private func sendPing() {
        guard case .connected = state else {
            logger?.warning("Tried to send ping but not connected")
            return
        }

        logger?.debug("Sending socket ping")

        do {
            let options = JSONRPCOptions(resendOnReconnect: false)
            _ = try callMethod(
                RPCMethod.helthCheck,
                params: [String](),
                options: options
            ) { [weak self] (result: Result<Health, Error>) in
                self?.handlePing(result: result)
            }
        } catch {
            logger?.error("Did receive ping error: \(error)")
        }
    }

    private func handlePing(result: Result<Health, Error>) {
        switch result {
        case let .success(health):
            if health.isSyncing {
                logger?.warning("Node is not healthy")
            }
        case let .failure(error):
            logger?.error("Health check error: \(error)")
        }
    }

    private func handlePing(scheduler: SchedulerProtocol) {
        schedulePingIfNeeded()
        connection.callbackQueue.async {
            self.sendPing()
        }
    }

    // MARK: - Notification

    private func notify(request: JSONRPCRequest, data: Data) {
        completionQueue.async {
            request.responseHandler?.handle(data: data)
        }
    }

    private func notify(requests: [JSONRPCRequest], error: Error) {
        guard !requests.isEmpty else { return }

        completionQueue.async {
            for request in requests {
                request.responseHandler?.handle(error: error)
            }
        }
    }

    // MARK: - Request Preparation

    public func prepareRequest<P: Codable, T: Decodable>(
        method: String,
        params: P?,
        options: JSONRPCOptions,
        completion closure: ((Result<T, Error>) -> Void)?
    ) throws -> JSONRPCRequest {
        let data: Data

        let requestId = generateRequestId()

        if let params = params {
            let info = JSONRPCInfo(
                identifier: requestId,
                jsonrpc: version,
                method: method,
                params: params
            )

            data = try jsonEncoder.encode(info)
        } else {
            let info = JSONRPCInfo(
                identifier: requestId,
                jsonrpc: version,
                method: method,
                params: [String]()
            )

            data = try jsonEncoder.encode(info)
        }

        let handler: JSONRPCResponseHandling?

        if let completionClosure = closure {
            handler = JSONRPCResponseHandler(completionClosure: completionClosure)
        } else {
            handler = nil
        }

        let request = JSONRPCRequest(
            requestId: requestId,
            data: data,
            options: options,
            responseHandler: handler
        )

        return request
    }

    public func generateRequestId() -> UInt16 {
        let items = pendingRequests.map(\.requestId) + inProgressRequests.map(\.key)
        let existingIds: Set<UInt16> = Set(items)

        let targetId = (1 ... UInt16.max).randomElement() ?? 1

        if existingIds.contains(targetId) {
            return generateRequestId()
        }

        return targetId
    }

    private func cancelRequestForLocalId(_ identifier: UInt16) {
        if let index = pendingRequests.firstIndex(where: { $0.requestId == identifier }) {
            let request = pendingRequests.remove(at: index)
            notify(requests: [request], error: JSONRPCEngineError.clientCancelled)
        } else if let request = inProgressRequests.removeValue(forKey: identifier) {
            notify(requests: [request], error: JSONRPCEngineError.clientCancelled)
        }
    }
}

// MARK: - WebSocketDelegate

extension WebSocketEngine: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        mutex.lock()
        defer { mutex.unlock() }

        switch event {
        case .binary(let data):
            handleBinaryEvent(data: data)
        case .text(let string):
            handleTextEvent(string: string)
        case .connected:
            handleConnectedEvent()
        case .disconnected(let reason, let code):
            handleDisconnectedEvent(reason: reason, code: code)
        case .error(let error):
            handleErrorEvent(error)
        case .cancelled:
            handleCancelled()
        case .viabilityChanged(let isViable):
            handleViabilityChanged(isViable: isViable)
        case .reconnectSuggested(let shouldReconnect):
            handleReconnectSuggested(shouldReconnect)
        default:
            logger?.debug("Unhandled websocket event: \(event)")
        }
    }

    private func handleBinaryEvent(data: Data) {
        logger?.debug("Did receive binary data: \(data.count) bytes")
        process(data: data)
    }

    private func handleTextEvent(string: String) {
        logger?.debug("Did receive text: \(string.prefix(1024))")
        if let data = string.data(using: .utf8) {
            process(data: data)
        }
    }

    private func handleConnectedEvent() {
        logger?.debug("Connection established")
        state = .connected
        sendAllPendingRequests()
        schedulePingIfNeeded()
    }

    private func handleDisconnectedEvent(reason: String, code: UInt16) {
        logger?.debug("Disconnected with code \(code): \(reason)")

        switch state {
        case .connecting(let attempt):
            attemptReconnection(attempt + 1)
        case .connected:
            let cancelledRequests = resetInProgress()
            pingScheduler.cancel()
            attemptReconnection(1)
            notify(requests: cancelledRequests, error: JSONRPCEngineError.remoteCancelled)
        default:
            break
        }
    }

    private func handleErrorEvent(_ error: Error?) {
        let errorDesc = error?.localizedDescription ?? "unknown error"
        logger?.error("WebSocket error: \(errorDesc)")

        let isTimeout = (error as? NWError) == .posix(.ETIMEDOUT)
        let isSocketNotConnected = (error as? WSError)?.code == 1 // Starscream's "socket not connected" error

        mutex.lock()
        defer { mutex.unlock() }

        switch state {
        case .connected:
            logger?.debug("Handling error in connected state")
            let cancelledRequests = resetInProgress()
            pingScheduler.cancel()

            recreateConnection()
            startConnecting(1)

            notify(requests: cancelledRequests, error: JSONRPCEngineError.remoteCancelled)

        case .connecting(let attempt) where isTimeout || isSocketNotConnected:
            logger?.debug("Handling timeout/socket error during connection attempt \(attempt)")
            connection.forceDisconnect()
            recreateConnection()
            attemptReconnection(attempt + 1, error: error)

        case .connecting(let attempt):
            logger?.debug("Handling other error during connection attempt \(attempt)")
            connection.forceDisconnect()
            attemptReconnection(attempt + 1, error: error)

        default:
            break
        }
    }

    private func recreateConnection() {
        guard let url = url else { return }

        let request = URLRequest(url: url, timeoutInterval: 10)
        let newEngine = WSEngine(transport: TCPTransport(), certPinner: FoundationSecurity())
        let newConnection = WebSocket(request: request, engine: newEngine)

        newConnection.callbackQueue = connection.callbackQueue
        newConnection.delegate = self

        connection.delegate = nil
        connection = newConnection
        engine = newEngine

        logger?.debug("Created new WebSocket connection instance")
    }

    private func handleCancelled() {
        logger?.debug("Connection cancelled")

        switch state {
        case .connecting(let attempt):
            connection.forceDisconnect()
            attemptReconnection(attempt + 1)
        case .connected:
            let cancelledRequests = resetInProgress()
            pingScheduler.cancel()
            connection.forceDisconnect()
            attemptReconnection(1)
            notify(requests: cancelledRequests, error: JSONRPCEngineError.clientCancelled)
        default:
            break
        }
    }

    private func handleViabilityChanged(isViable: Bool) {
        logger?.debug("Connection viability changed: \(isViable)")

        if !isViable {
            let cancelledRequests = resetInProgress()
            pingScheduler.cancel()
            connection.forceDisconnect()
            notify(requests: cancelledRequests, error: JSONRPCEngineError.networkNotReachable)
            state = .notConnected
        } else if !state.isConnected {
            reconnectImmediately()
        }
    }

    private func handleReconnectSuggested(_ shouldReconnect: Bool) {
        logger?.debug("Reconnect suggested: \(shouldReconnect)")

        if shouldReconnect && !state.isConnected {
            reconnectImmediately()
        }
    }
}

// MARK: - SchedulerDelegate

extension WebSocketEngine: SchedulerDelegate {
    public func didTrigger(scheduler: SchedulerProtocol) {
        mutex.lock()
        defer { mutex.unlock() }

        if scheduler === pingScheduler {
            handlePing(scheduler: scheduler)
        } else {
            handleReconnection(scheduler: scheduler)
        }
    }

    private func handleReconnection(scheduler: SchedulerProtocol) {
        logger?.debug("Reconnection triggered")
        startConnecting(1)
    }
}

// MARK: - JSONRPCEngine

extension WebSocketEngine: JSONRPCEngine {
    public var pendingEngineRequests: [JSONRPCRequest] {
        pendingRequests
    }

    public func callMethod<P: Codable, T: Decodable>(
        _ method: String,
        params: P?,
        options: JSONRPCOptions,
        completion closure: ((Result<T, Error>) -> Void)?
    ) throws -> UInt16 {
        mutex.lock()
        defer { mutex.unlock() }

        let request = try prepareRequest(
            method: method,
            params: params,
            options: options,
            completion: closure
        )

        updateConnectionForRequest(request)

        return request.requestId
    }

    public func subscribe<P: Codable, T: Decodable>(
        _ method: String,
        params: P?,
        updateClosure: @escaping (T) -> Void,
        failureClosure: @escaping (Error, Bool) -> Void
    ) throws -> UInt16 {
        mutex.lock()
        defer { mutex.unlock() }

        let completion: ((Result<String, Error>) -> Void)? = nil

        let request = try prepareRequest(
            method: method,
            params: params,
            options: JSONRPCOptions(resendOnReconnect: true),
            completion: completion
        )

        let subscription = JSONRPCSubscription(
            requestId: request.requestId,
            requestData: request.data,
            requestOptions: request.options,
            updateClosure: updateClosure,
            failureClosure: failureClosure
        )

        addSubscription(subscription)
        updateConnectionForRequest(request)

        return request.requestId
    }

    public func cancelForIdentifier(_ identifier: UInt16) {
        mutex.lock()
        defer { mutex.unlock() }

        cancelRequestForLocalId(identifier)
    }

    public func reconnect(url: URL) {
        mutex.lock()
        defer { mutex.unlock() }

        self.connection.delegate = nil
        self.url = url
        let request = URLRequest(url: url, timeoutInterval: 10)

        let connection = WebSocket(request: request, engine: engine)
        self.connection = connection

        connection.callbackQueue = Self.sharedProcessingQueue
        connection.delegate = self

        reconnectImmediately()
    }
}
