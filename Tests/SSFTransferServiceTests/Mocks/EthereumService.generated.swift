// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFTransferService
@testable import SSFModels
@testable import Web3
@testable import Web3ContractABI

class EthereumServiceMock: EthereumService {
    var connection: Web3.Eth {
        get { return underlyingConnection }
        set(value) { underlyingConnection = value }
    }
    var underlyingConnection: Web3.Eth!
    var hasSubscription: Bool {
        get { return underlyingHasSubscription }
        set(value) { underlyingHasSubscription = value }
    }
    var underlyingHasSubscription: Bool!

    //MARK: - send

    var sendThrowableError: Error?
    var sendCallsCount = 0
    var sendCalled: Bool {
        return sendCallsCount > 0
    }
    var sendReceivedTransaction: EthereumSignedTransaction?
    var sendReceivedInvocations: [EthereumSignedTransaction] = []
    var sendReturnValue: EthereumData!
    var sendClosure: ((EthereumSignedTransaction) throws -> EthereumData)?

    func send(_ transaction: EthereumSignedTransaction) throws -> EthereumData {
        if let error = sendThrowableError {
            throw error
        }
        sendCallsCount += 1
        sendReceivedTransaction = transaction
        sendReceivedInvocations.append(transaction)
        return try sendClosure.map({ try $0(transaction) }) ?? sendReturnValue
    }

    //MARK: - queryGasLimit

    var queryGasLimitCallThrowableError: Error?
    var queryGasLimitCallCallsCount = 0
    var queryGasLimitCallCalled: Bool {
        return queryGasLimitCallCallsCount > 0
    }
    var queryGasLimitCallReceivedCall: EthereumCall?
    var queryGasLimitCallReceivedInvocations: [EthereumCall] = []
    var queryGasLimitCallReturnValue: EthereumQuantity!
    var queryGasLimitCallClosure: ((EthereumCall) throws -> EthereumQuantity)?

    func queryGasLimit(call: EthereumCall) throws -> EthereumQuantity {
        if let error = queryGasLimitCallThrowableError {
            throw error
        }
        queryGasLimitCallCallsCount += 1
        queryGasLimitCallReceivedCall = call
        queryGasLimitCallReceivedInvocations.append(call)
        return try queryGasLimitCallClosure.map({ try $0(call) }) ?? queryGasLimitCallReturnValue
    }

    //MARK: - queryGasLimit

    var queryGasLimitFromAmountTransferThrowableError: Error?
    var queryGasLimitFromAmountTransferCallsCount = 0
    var queryGasLimitFromAmountTransferCalled: Bool {
        return queryGasLimitFromAmountTransferCallsCount > 0
    }
    var queryGasLimitFromAmountTransferReceivedArguments: (from: EthereumAddress?, amount: EthereumQuantity?, transfer: SolidityInvocation)?
    var queryGasLimitFromAmountTransferReceivedInvocations: [(from: EthereumAddress?, amount: EthereumQuantity?, transfer: SolidityInvocation)] = []
    var queryGasLimitFromAmountTransferReturnValue: EthereumQuantity!
    var queryGasLimitFromAmountTransferClosure: ((EthereumAddress?, EthereumQuantity?, SolidityInvocation) throws -> EthereumQuantity)?

    func queryGasLimit(from: EthereumAddress?, amount: EthereumQuantity?, transfer: SolidityInvocation) throws -> EthereumQuantity {
        if let error = queryGasLimitFromAmountTransferThrowableError {
            throw error
        }
        queryGasLimitFromAmountTransferCallsCount += 1
        queryGasLimitFromAmountTransferReceivedArguments = (from: from, amount: amount, transfer: transfer)
        queryGasLimitFromAmountTransferReceivedInvocations.append((from: from, amount: amount, transfer: transfer))
        return try queryGasLimitFromAmountTransferClosure.map({ try $0(from, amount, transfer) }) ?? queryGasLimitFromAmountTransferReturnValue
    }

    //MARK: - queryGasPrice

    var queryGasPriceThrowableError: Error?
    var queryGasPriceCallsCount = 0
    var queryGasPriceCalled: Bool {
        return queryGasPriceCallsCount > 0
    }
    var queryGasPriceReturnValue: EthereumQuantity!
    var queryGasPriceClosure: (() throws -> EthereumQuantity)?

    func queryGasPrice() throws -> EthereumQuantity {
        if let error = queryGasPriceThrowableError {
            throw error
        }
        queryGasPriceCallsCount += 1
        return try queryGasPriceClosure.map({ try $0() }) ?? queryGasPriceReturnValue
    }

    //MARK: - queryMaxPriorityFeePerGas

    var queryMaxPriorityFeePerGasThrowableError: Error?
    var queryMaxPriorityFeePerGasCallsCount = 0
    var queryMaxPriorityFeePerGasCalled: Bool {
        return queryMaxPriorityFeePerGasCallsCount > 0
    }
    var queryMaxPriorityFeePerGasReturnValue: EthereumQuantity!
    var queryMaxPriorityFeePerGasClosure: (() throws -> EthereumQuantity)?

    func queryMaxPriorityFeePerGas() throws -> EthereumQuantity {
        if let error = queryMaxPriorityFeePerGasThrowableError {
            throw error
        }
        queryMaxPriorityFeePerGasCallsCount += 1
        return try queryMaxPriorityFeePerGasClosure.map({ try $0() }) ?? queryMaxPriorityFeePerGasReturnValue
    }

    //MARK: - queryNonce

    var queryNonceEthereumAddressThrowableError: Error?
    var queryNonceEthereumAddressCallsCount = 0
    var queryNonceEthereumAddressCalled: Bool {
        return queryNonceEthereumAddressCallsCount > 0
    }
    var queryNonceEthereumAddressReceivedEthereumAddress: EthereumAddress?
    var queryNonceEthereumAddressReceivedInvocations: [EthereumAddress] = []
    var queryNonceEthereumAddressReturnValue: EthereumQuantity!
    var queryNonceEthereumAddressClosure: ((EthereumAddress) throws -> EthereumQuantity)?

    func queryNonce(ethereumAddress: EthereumAddress) throws -> EthereumQuantity {
        if let error = queryNonceEthereumAddressThrowableError {
            throw error
        }
        queryNonceEthereumAddressCallsCount += 1
        queryNonceEthereumAddressReceivedEthereumAddress = ethereumAddress
        queryNonceEthereumAddressReceivedInvocations.append(ethereumAddress)
        return try queryNonceEthereumAddressClosure.map({ try $0(ethereumAddress) }) ?? queryNonceEthereumAddressReturnValue
    }

    //MARK: - checkChainSupportEip1559

    var checkChainSupportEip1559CallsCount = 0
    var checkChainSupportEip1559Called: Bool {
        return checkChainSupportEip1559CallsCount > 0
    }
    var checkChainSupportEip1559ReturnValue: Bool!
    var checkChainSupportEip1559Closure: (() -> Bool)?

    func checkChainSupportEip1559() -> Bool {
        checkChainSupportEip1559CallsCount += 1
        return checkChainSupportEip1559Closure.map({ $0() }) ?? checkChainSupportEip1559ReturnValue
    }

    //MARK: - unsubscribe

    var unsubscribeSubscriptionIdThrowableError: Error?
    var unsubscribeSubscriptionIdCallsCount = 0
    var unsubscribeSubscriptionIdCalled: Bool {
        return unsubscribeSubscriptionIdCallsCount > 0
    }
    var unsubscribeSubscriptionIdReceivedSubscriptionId: String?
    var unsubscribeSubscriptionIdReceivedInvocations: [String] = []
    var unsubscribeSubscriptionIdReturnValue: Bool!
    var unsubscribeSubscriptionIdClosure: ((String) throws -> Bool)?

    func unsubscribe(subscriptionId: String) throws -> Bool {
        if let error = unsubscribeSubscriptionIdThrowableError {
            throw error
        }
        unsubscribeSubscriptionIdCallsCount += 1
        unsubscribeSubscriptionIdReceivedSubscriptionId = subscriptionId
        unsubscribeSubscriptionIdReceivedInvocations.append(subscriptionId)
        return try unsubscribeSubscriptionIdClosure.map({ try $0(subscriptionId) }) ?? unsubscribeSubscriptionIdReturnValue
    }

    //MARK: - getBlockByNumber

    var getBlockByNumberBlockFullTransactionObjectsThrowableError: Error?
    var getBlockByNumberBlockFullTransactionObjectsCallsCount = 0
    var getBlockByNumberBlockFullTransactionObjectsCalled: Bool {
        return getBlockByNumberBlockFullTransactionObjectsCallsCount > 0
    }
    var getBlockByNumberBlockFullTransactionObjectsReceivedArguments: (block: EthereumQuantityTag, fullTransactionObjects: Bool)?
    var getBlockByNumberBlockFullTransactionObjectsReceivedInvocations: [(block: EthereumQuantityTag, fullTransactionObjects: Bool)] = []
    var getBlockByNumberBlockFullTransactionObjectsReturnValue: EthereumBlockObject?
    var getBlockByNumberBlockFullTransactionObjectsClosure: ((EthereumQuantityTag, Bool) throws -> EthereumBlockObject?)?

    func getBlockByNumber(block: EthereumQuantityTag, fullTransactionObjects: Bool) throws -> EthereumBlockObject? {
        if let error = getBlockByNumberBlockFullTransactionObjectsThrowableError {
            throw error
        }
        getBlockByNumberBlockFullTransactionObjectsCallsCount += 1
        getBlockByNumberBlockFullTransactionObjectsReceivedArguments = (block: block, fullTransactionObjects: fullTransactionObjects)
        getBlockByNumberBlockFullTransactionObjectsReceivedInvocations.append((block: block, fullTransactionObjects: fullTransactionObjects))
        return try getBlockByNumberBlockFullTransactionObjectsClosure.map({ try $0(block, fullTransactionObjects) }) ?? getBlockByNumberBlockFullTransactionObjectsReturnValue
    }

}
