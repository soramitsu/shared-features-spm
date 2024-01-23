// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import IrohaCrypto
@testable import SSFKeyPair
@testable import SSFModels
@testable import SSFCrypto

class MnemonicCreatorMock: MnemonicCreator {

    //MARK: - randomMnemonic

    var randomMnemonicStrengthThrowableError: Error?
    var randomMnemonicStrengthCallsCount = 0
    var randomMnemonicStrengthCalled: Bool {
        return randomMnemonicStrengthCallsCount > 0
    }
    var randomMnemonicStrengthReceivedStrength: IRMnemonicStrength?
    var randomMnemonicStrengthReceivedInvocations: [IRMnemonicStrength] = []
    var randomMnemonicStrengthReturnValue: IRMnemonicProtocol!
    var randomMnemonicStrengthClosure: ((IRMnemonicStrength) throws -> IRMnemonicProtocol)?

    func randomMnemonic(strength: IRMnemonicStrength) throws -> IRMnemonicProtocol {
        if let error = randomMnemonicStrengthThrowableError {
            throw error
        }
        randomMnemonicStrengthCallsCount += 1
        randomMnemonicStrengthReceivedStrength = strength
        randomMnemonicStrengthReceivedInvocations.append(strength)
        return try randomMnemonicStrengthClosure.map({ try $0(strength) }) ?? randomMnemonicStrengthReturnValue
    }

    //MARK: - mnemonic

    var mnemonicFromListThrowableError: Error?
    var mnemonicFromListCallsCount = 0
    var mnemonicFromListCalled: Bool {
        return mnemonicFromListCallsCount > 0
    }
    var mnemonicFromListReceivedMnemonicPhrase: String?
    var mnemonicFromListReceivedInvocations: [String] = []
    var mnemonicFromListReturnValue: IRMnemonicProtocol!
    var mnemonicFromListClosure: ((String) throws -> IRMnemonicProtocol)?

    func mnemonic(fromList mnemonicPhrase: String) throws -> IRMnemonicProtocol {
        if let error = mnemonicFromListThrowableError {
            throw error
        }
        mnemonicFromListCallsCount += 1
        mnemonicFromListReceivedMnemonicPhrase = mnemonicPhrase
        mnemonicFromListReceivedInvocations.append(mnemonicPhrase)
        return try mnemonicFromListClosure.map({ try $0(mnemonicPhrase) }) ?? mnemonicFromListReturnValue
    }

    //MARK: - mnemonic

    var mnemonicFromEntropyThrowableError: Error?
    var mnemonicFromEntropyCallsCount = 0
    var mnemonicFromEntropyCalled: Bool {
        return mnemonicFromEntropyCallsCount > 0
    }
    var mnemonicFromEntropyReceivedEntropy: Data?
    var mnemonicFromEntropyReceivedInvocations: [Data] = []
    var mnemonicFromEntropyReturnValue: IRMnemonicProtocol!
    var mnemonicFromEntropyClosure: ((Data) throws -> IRMnemonicProtocol)?

    func mnemonic(fromEntropy entropy: Data) throws -> IRMnemonicProtocol {
        if let error = mnemonicFromEntropyThrowableError {
            throw error
        }
        mnemonicFromEntropyCallsCount += 1
        mnemonicFromEntropyReceivedEntropy = entropy
        mnemonicFromEntropyReceivedInvocations.append(entropy)
        return try mnemonicFromEntropyClosure.map({ try $0(entropy) }) ?? mnemonicFromEntropyReturnValue
    }

}
