import Foundation
import Starscream

extension WebSocketEngine: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client _: WebSocketClient) {
        debugPrint(event)
        
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
        case .viabilityChanged(_):
            // Ignore viability here; reachability + errors drive reconnection
            logger?.debug("viabilityChanged event received")
        case .reconnectSuggested(let suggested):
            //guard suggested else { return }
            //recreateConnection()
            //startConnecting(0)
            
            logger?.debug("reconnectSuggested event received")
        case .ping(_):
            // Ignore ping event; health is tracked separately
            logger?.debug("Ping event received")
        default:
            logger?.warning("Unhandled event \(event)")
        }
    }

    private func handleCancelled() {
        logger?.warning("Remote cancelled")

        switch state {
        case let .connecting(attempt):
            connection.disconnect()
            scheduleReconnectionOrDisconnect(attempt + 1)
        case .connected:
            let cancelledRequests = resetInProgress()

            pingScheduler.cancel()

            connection.disconnect()
            scheduleReconnectionOrDisconnect(1)

            notify(
                requests: cancelledRequests,
                error: JSONRPCEngineError.clientCancelled
            )
        default:
            break
        }
    }

    private func handleErrorEvent(_ error: Error?) {
        debugPrint(error)
        if let error = error {
            logger?.error("Did receive error: \(error)")
        } else {
            logger?.error("Did receive unknown error")
        }

        switch state {
        case .connected:
            let cancelledRequests = resetInProgress()

            pingScheduler.cancel()

            if shouldRecreateConnection(after: error) {
                recreateConnection()
                startConnecting(0)
            } else {
                connection.disconnect()
                startConnecting(0)
            }

            notify(
                requests: cancelledRequests,
                error: JSONRPCEngineError.clientCancelled
            )
        case let .connecting(attempt):
            if shouldRecreateConnection(after: error) {
                recreateConnection()
            } else {
                connection.disconnect()
            }
            scheduleReconnectionOrDisconnect(attempt + 1)
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

        switch state {
        case let .connecting(attempt):
            scheduleReconnectionOrDisconnect(attempt + 1)
        case .connected:
            let cancelledRequests = resetInProgress()

            pingScheduler.cancel()

            scheduleReconnectionOrDisconnect(1)

            notify(
                requests: cancelledRequests,
                error: JSONRPCEngineError.remoteCancelled
            )
        default:
            break
        }
    }

    // Removed active handling for viabilityChanged/reconnectSuggested to avoid races.
}

extension WebSocketEngine: ReachabilityListenerDelegate {
    public func didChangeReachability(by manager: ReachabilityManagerProtocol) {
        mutex.lock()

        let isReachable = manager.isReachable
        let currentState = state

        if isReachable {
            logger?.debug("Network became reachable, retrying connection")
            if case .waitingReconnection = currentState {
                reconnectionScheduler.cancel()
                startConnecting(0)
            } else if case .notConnected = currentState {
                startConnecting(0)
            }
        }

        mutex.unlock()
    }
}

extension WebSocketEngine: SchedulerDelegate {
    public func didTrigger(scheduler: SchedulerProtocol) {
        mutex.lock()
        defer {
            mutex.unlock()
        }

        if scheduler === pingScheduler {
            handlePing(scheduler: scheduler)
        } else {
            handleReconnection(scheduler: scheduler)
        }
    }

    private func handleReconnection(scheduler _: SchedulerProtocol) {
        logger?.debug("Did trigger reconnection scheduler")

        if case let .waitingReconnection(attempt) = state {
            startConnecting(attempt)
        }
    }

    private func handlePing(scheduler _: SchedulerProtocol) {
        schedulePingIfNeeded()

        connection.callbackQueue.async {
            self.sendPing()
        }
    }
}

// MARK: - Error classification
extension WebSocketEngine {
    fileprivate func shouldRecreateConnection(after error: Error?) -> Bool {
        guard let error = error else { return false }
        if let wsError = error as? WSError {
            if wsError.code == 1002 || wsError.type == .protocolError {
                return true
            }
        }
        if let posix = error as? POSIXError {
            switch posix.code {
            case .ECONNRESET, .ENOTCONN, .ETIMEDOUT:
                return true
            default:
                break
            }
        }
        return false
    }
}
