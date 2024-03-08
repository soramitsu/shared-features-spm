// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFRuntimeCodingService
@testable import SSFUtils
@testable import RobinHood
@testable import SSFModels

public class RuntimeProviderProtocolMock: RuntimeProviderProtocol {
public init() {}
    public var runtimeSpecVersion: RuntimeSpecVersion {
        get { return underlyingRuntimeSpecVersion }
        set(value) { underlyingRuntimeSpecVersion = value }
    }
    public var underlyingRuntimeSpecVersion: RuntimeSpecVersion!
    public var snapshot: RuntimeSnapshot?

    //MARK: - setup

    public var setupCallsCount = 0
    public var setupCalled: Bool {
        return setupCallsCount > 0
    }
    public var setupClosure: (() -> Void)?

    public func setup() {
        setupCallsCount += 1
        setupClosure?()
    }

    //MARK: - readySnapshot

    public var readySnapshotThrowableError: Error?
    public var readySnapshotCallsCount = 0
    public var readySnapshotCalled: Bool {
        return readySnapshotCallsCount > 0
    }
    public var readySnapshotReturnValue: RuntimeSnapshot!
    public var readySnapshotClosure: (() throws -> RuntimeSnapshot)?

    public func readySnapshot() throws -> RuntimeSnapshot {
        if let error = readySnapshotThrowableError {
            throw error
        }
        readySnapshotCallsCount += 1
        return try readySnapshotClosure.map({ try $0() }) ?? readySnapshotReturnValue
    }

    //MARK: - cleanup

    public var cleanupCallsCount = 0
    public var cleanupCalled: Bool {
        return cleanupCallsCount > 0
    }
    public var cleanupClosure: (() -> Void)?

    public func cleanup() {
        cleanupCallsCount += 1
        cleanupClosure?()
    }

    //MARK: - fetchCoderFactoryOperation

    public var fetchCoderFactoryOperationCallsCount = 0
    public var fetchCoderFactoryOperationCalled: Bool {
        return fetchCoderFactoryOperationCallsCount > 0
    }
    public var fetchCoderFactoryOperationReturnValue: BaseOperation<RuntimeCoderFactoryProtocol>!
    public var fetchCoderFactoryOperationClosure: (() -> BaseOperation<RuntimeCoderFactoryProtocol>)?

    public func fetchCoderFactoryOperation() -> BaseOperation<RuntimeCoderFactoryProtocol> {
        fetchCoderFactoryOperationCallsCount += 1
        return fetchCoderFactoryOperationClosure.map({ $0() }) ?? fetchCoderFactoryOperationReturnValue
    }

    //MARK: - fetchCoderFactory

    public var fetchCoderFactoryThrowableError: Error?
    public var fetchCoderFactoryCallsCount = 0
    public var fetchCoderFactoryCalled: Bool {
        return fetchCoderFactoryCallsCount > 0
    }
    public var fetchCoderFactoryReturnValue: RuntimeCoderFactoryProtocol!
    public var fetchCoderFactoryClosure: (() throws -> RuntimeCoderFactoryProtocol)?

    public func fetchCoderFactory() throws -> RuntimeCoderFactoryProtocol {
        if let error = fetchCoderFactoryThrowableError {
            throw error
        }
        fetchCoderFactoryCallsCount += 1
        return try fetchCoderFactoryClosure.map({ try $0() }) ?? fetchCoderFactoryReturnValue
    }

}
