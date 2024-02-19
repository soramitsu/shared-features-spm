// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import IrohaCrypto
@testable import SSFCrypto
@testable import SSFKeyPair
@testable import SSFModels

class CommonCryptoMock: CommonCrypto {
    // MARK: - getQuery

    var getQuerySeedDerivationPathCryptoTypeEthereumBasedThrowableError: Error?
    var getQuerySeedDerivationPathCryptoTypeEthereumBasedCallsCount = 0
    var getQuerySeedDerivationPathCryptoTypeEthereumBasedCalled: Bool {
        getQuerySeedDerivationPathCryptoTypeEthereumBasedCallsCount > 0
    }

    var getQuerySeedDerivationPathCryptoTypeEthereumBasedReceivedArguments: (
        seed: Data,
        derivationPath: String,
        cryptoType: CryptoType,
        ethereumBased: Bool
    )?
    var getQuerySeedDerivationPathCryptoTypeEthereumBasedReceivedInvocations: [(
        seed: Data,
        derivationPath: String,
        cryptoType: CryptoType,
        ethereumBased: Bool
    )] = []
    var getQuerySeedDerivationPathCryptoTypeEthereumBasedReturnValue: AccountQuery!
    var getQuerySeedDerivationPathCryptoTypeEthereumBasedClosure: ((
        Data,
        String,
        CryptoType,
        Bool
    ) throws -> AccountQuery)?

    func getQuery(
        seed: Data,
        derivationPath: String,
        cryptoType: CryptoType,
        ethereumBased: Bool
    ) throws -> AccountQuery {
        if let error = getQuerySeedDerivationPathCryptoTypeEthereumBasedThrowableError {
            throw error
        }
        getQuerySeedDerivationPathCryptoTypeEthereumBasedCallsCount += 1
        getQuerySeedDerivationPathCryptoTypeEthereumBasedReceivedArguments = (
            seed: seed,
            derivationPath: derivationPath,
            cryptoType: cryptoType,
            ethereumBased: ethereumBased
        )
        getQuerySeedDerivationPathCryptoTypeEthereumBasedReceivedInvocations.append((
            seed: seed,
            derivationPath: derivationPath,
            cryptoType: cryptoType,
            ethereumBased: ethereumBased
        ))
        return try getQuerySeedDerivationPathCryptoTypeEthereumBasedClosure.map { try $0(
            seed,
            derivationPath,
            cryptoType,
            ethereumBased
        ) } ?? getQuerySeedDerivationPathCryptoTypeEthereumBasedReturnValue
    }

    // MARK: - getJunctionResult

    var getJunctionResultFromEthereumBasedThrowableError: Error?
    var getJunctionResultFromEthereumBasedCallsCount = 0
    var getJunctionResultFromEthereumBasedCalled: Bool {
        getJunctionResultFromEthereumBasedCallsCount > 0
    }

    var getJunctionResultFromEthereumBasedReceivedArguments: (
        derivationPath: String,
        ethereumBased: Bool
    )?
    var getJunctionResultFromEthereumBasedReceivedInvocations: [(
        derivationPath: String,
        ethereumBased: Bool
    )] = []
    var getJunctionResultFromEthereumBasedReturnValue: JunctionResult?
    var getJunctionResultFromEthereumBasedClosure: ((String, Bool) throws -> JunctionResult?)?

    func getJunctionResult(
        from derivationPath: String,
        ethereumBased: Bool
    ) throws -> JunctionResult? {
        if let error = getJunctionResultFromEthereumBasedThrowableError {
            throw error
        }
        getJunctionResultFromEthereumBasedCallsCount += 1
        getJunctionResultFromEthereumBasedReceivedArguments = (
            derivationPath: derivationPath,
            ethereumBased: ethereumBased
        )
        getJunctionResultFromEthereumBasedReceivedInvocations.append((
            derivationPath: derivationPath,
            ethereumBased: ethereumBased
        ))
        return try getJunctionResultFromEthereumBasedClosure.map { try $0(
            derivationPath,
            ethereumBased
        ) } ?? getJunctionResultFromEthereumBasedReturnValue
    }

    // MARK: - generateKeypair

    var generateKeypairFromChaincodesCryptoTypeIsEthereumThrowableError: Error?
    var generateKeypairFromChaincodesCryptoTypeIsEthereumCallsCount = 0
    var generateKeypairFromChaincodesCryptoTypeIsEthereumCalled: Bool {
        generateKeypairFromChaincodesCryptoTypeIsEthereumCallsCount > 0
    }

    var generateKeypairFromChaincodesCryptoTypeIsEthereumReceivedArguments: (
        seed: Data,
        chaincodes: [Chaincode],
        cryptoType: CryptoType,
        isEthereum: Bool
    )?
    var generateKeypairFromChaincodesCryptoTypeIsEthereumReceivedInvocations: [(
        seed: Data,
        chaincodes: [Chaincode],
        cryptoType: CryptoType,
        isEthereum: Bool
    )] = []
    var generateKeypairFromChaincodesCryptoTypeIsEthereumReturnValue: (
        publicKey: Data,
        secretKey: Data
    )!
    var generateKeypairFromChaincodesCryptoTypeIsEthereumClosure: ((
        Data,
        [Chaincode],
        CryptoType,
        Bool
    ) throws -> (publicKey: Data, secretKey: Data))?

    func generateKeypair(
        from seed: Data,
        chaincodes: [Chaincode],
        cryptoType: CryptoType,
        isEthereum: Bool
    ) throws -> (publicKey: Data, secretKey: Data) {
        if let error = generateKeypairFromChaincodesCryptoTypeIsEthereumThrowableError {
            throw error
        }
        generateKeypairFromChaincodesCryptoTypeIsEthereumCallsCount += 1
        generateKeypairFromChaincodesCryptoTypeIsEthereumReceivedArguments = (
            seed: seed,
            chaincodes: chaincodes,
            cryptoType: cryptoType,
            isEthereum: isEthereum
        )
        generateKeypairFromChaincodesCryptoTypeIsEthereumReceivedInvocations.append((
            seed: seed,
            chaincodes: chaincodes,
            cryptoType: cryptoType,
            isEthereum: isEthereum
        ))
        return try generateKeypairFromChaincodesCryptoTypeIsEthereumClosure.map { try $0(
            seed,
            chaincodes,
            cryptoType,
            isEthereum
        ) } ?? generateKeypairFromChaincodesCryptoTypeIsEthereumReturnValue
    }

    // MARK: - createKeypairFactory

    var createKeypairFactoryIsEthereumBasedCallsCount = 0
    var createKeypairFactoryIsEthereumBasedCalled: Bool {
        createKeypairFactoryIsEthereumBasedCallsCount > 0
    }

    var createKeypairFactoryIsEthereumBasedReceivedArguments: (
        cryptoType: CryptoType,
        isEthereumBased: Bool
    )?
    var createKeypairFactoryIsEthereumBasedReceivedInvocations: [(
        cryptoType: CryptoType,
        isEthereumBased: Bool
    )] = []
    var createKeypairFactoryIsEthereumBasedReturnValue: KeypairFactoryProtocol!
    var createKeypairFactoryIsEthereumBasedClosure: ((CryptoType, Bool) -> KeypairFactoryProtocol)?

    func createKeypairFactory(
        _ cryptoType: CryptoType,
        isEthereumBased: Bool
    ) -> KeypairFactoryProtocol {
        createKeypairFactoryIsEthereumBasedCallsCount += 1
        createKeypairFactoryIsEthereumBasedReceivedArguments = (
            cryptoType: cryptoType,
            isEthereumBased: isEthereumBased
        )
        createKeypairFactoryIsEthereumBasedReceivedInvocations.append((
            cryptoType: cryptoType,
            isEthereumBased: isEthereumBased
        ))
        return createKeypairFactoryIsEthereumBasedClosure
            .map { $0(cryptoType, isEthereumBased) } ??
            createKeypairFactoryIsEthereumBasedReturnValue
    }
}
