import UIKit
@testable import IrohaCrypto

class IRMnemonicCreatorProtocolMock: NSObject, IRMnemonicCreatorProtocol {

    //MARK: - randomMnemonic

    var randomMnemonicStrengthThrowableError: Error?
    var randomMnemonicStrengthCallsCount = 0
    var randomMnemonicStrengthCalled: Bool {
        return randomMnemonicStrengthCallsCount > 0
    }
    var randomMnemonicStrengthReceivedStrength: IRMnemonicStrength?
    var randomMnemonicStrengthReceivedInvocations: [IRMnemonicStrength] = []
    var randomMnemonicStrengthReturnValue: IRMnemonicProtocol!

    func randomMnemonic(_ strength: IRMnemonicStrength) throws -> IRMnemonicProtocol {
        if let error = randomMnemonicStrengthThrowableError {
            throw error
        }
        randomMnemonicStrengthCallsCount += 1
        randomMnemonicStrengthReceivedStrength = strength
        randomMnemonicStrengthReceivedInvocations.append(strength)
        return randomMnemonicStrengthReturnValue
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

    func mnemonic(fromList mnemonicPhrase: String) throws -> IRMnemonicProtocol {
        if let error = mnemonicFromListThrowableError {
            throw error
        }
        mnemonicFromListCallsCount += 1
        mnemonicFromListReceivedMnemonicPhrase = mnemonicPhrase
        mnemonicFromListReceivedInvocations.append(mnemonicPhrase)
        return mnemonicFromListReturnValue
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

    func mnemonic(fromEntropy entropy: Data) throws -> IRMnemonicProtocol {
        if let error = mnemonicFromEntropyThrowableError {
            throw error
        }
        mnemonicFromEntropyCallsCount += 1
        mnemonicFromEntropyReceivedEntropy = entropy
        mnemonicFromEntropyReceivedInvocations.append(entropy)
        return mnemonicFromEntropyReturnValue
    }

}

