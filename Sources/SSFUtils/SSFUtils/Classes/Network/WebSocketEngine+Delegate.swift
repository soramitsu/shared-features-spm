import Foundation
import Starscream

extension WebSocketEngine: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client _: WebSocketClient) {
        mutex.lock()

        defer {
            mutex.unlock()
        }

        switch event {
        case let .binary(data):
            handleBinaryEvent(data: data)
        case let .text(string):
            handleTextEvent(string: string)
        case .connected:
            handleConnectedEvent()
        case let .disconnected(reason, code):
            handleDisconnectedEvent(reason: reason, code: code)
        case let .error(error):
            handleErrorEvent(error)
        case .cancelled:
            handleCancelled()
        case .timeout:
            handleTimeout()
        case let .waiting(error):
            handleDisconnectedEvent(reason: error.localizedDescription, code: 0)
        case .pong, .ping, .viabilityChanged:
            logger?.warning("Unhandled event \(event)")
        case let .reconnectSuggested(reconnectSuggested):
            logger?.warning("reconnectSuggested \(reconnectSuggested)")
            guard reconnectSuggested else {
                return
            }
            handleDisconnectedEvent(reason: "reconnect suggested", code: 0)
        }
    }

    private func handleTimeout() {
        handleCancelled(error: JSONRPCEngineError.timeout)
    }

    private func handleCancelled(error: Error? = nil) {
        logger?.warning("Remote cancelled")

        switch connectionStrategy.state {
        case .connecting:
            disconnect()
            scheduleReconnectionOrDisconnect()
        case .connected:
            let cancelledRequests = resetInProgress()

            pingScheduler.cancel()

            disconnect()
            scheduleReconnectionOrDisconnect()

            notify(
                requests: cancelledRequests,
                error: error ?? JSONRPCEngineError.clientCancelled
            )
        default:
            break
        }
    }

    private func handleErrorEvent(_ error: Error?) {
        if let error = error {
            logger?.error("Did receive error: \(error)")
        } else {
            logger?.error("Did receive unknown error")
        }

        switch connectionStrategy.state {
        case .connected:
            let cancelledRequests = resetInProgress()

            pingScheduler.cancel()

            disconnect()
            startConnecting()

            notify(
                requests: cancelledRequests,
                error: JSONRPCEngineError.clientCancelled
            )
        case .connecting:
            disconnect()

            scheduleReconnectionOrDisconnect(after: error)
        default:
            break
        }
    }

    private func handleBinaryEvent(data: Data) {
        if let decodedString = String(data: data, encoding: .utf8) {
            logger?.debug("Did receive data: \(decodedString.prefix(1024))")
        }

        process(data: data)
    }

    private func handleTextEvent(string: String) {
        logger?.debug("Did receive text: \(string.prefix(1024))")
        if let data = string.data(using: .utf8) {
            process(data: data)
        } else {
            logger?.warning("Unsupported text event: \(string)")
        }
    }

    private func handleConnectedEvent() {
        logger?.debug("connection established")

        changeState(.connected)
        sendAllPendingRequests()

        schedulePingIfNeeded()
    }

    private func handleDisconnectedEvent(reason: String, code: UInt16) {
        logger?.warning("Disconnected with code \(code): \(reason)")

        switch connectionStrategy.state {
        case .connecting:
            scheduleReconnectionOrDisconnect()
        case .connected:
            let cancelledRequests = resetInProgress()

            pingScheduler.cancel()

            scheduleReconnectionOrDisconnect()

            notify(
                requests: cancelledRequests,
                error: JSONRPCEngineError.remoteCancelled
            )
        default:
            break
        }
    }
}

extension WebSocketEngine: ReachabilityListenerDelegate {
    public func didChangeReachability(by manager: ReachabilityManagerProtocol) {
        mutex.lock()

        if manager.isReachable, case .notReachable = connectionStrategy.state {
            logger?.debug("Network became reachable, retrying connection")

            cancelReconectionShedule()
            startConnecting()
        }

        mutex.unlock()
    }
}

extension WebSocketEngine: SchedulerDelegate {
    public func didTrigger(scheduler: SchedulerProtocol) {
        mutex.lock()

        if scheduler === pingScheduler {
            handlePing(scheduler: scheduler)
        }

        mutex.unlock()
    }

    private func handlePing(scheduler _: SchedulerProtocol) {
        schedulePingIfNeeded()

        completionQueue.async {
            self.sendPing()
        }
    }
}
