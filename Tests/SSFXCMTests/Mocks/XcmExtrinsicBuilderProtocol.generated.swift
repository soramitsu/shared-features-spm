// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFXCM
@testable import SSFUtils
@testable import SSFNetwork
@testable import SSFModels
@testable import RobinHood
@testable import BigInt
@testable import SSFExtrinsicKit
@testable import SSFChainRegistry
@testable import SSFRuntimeCodingService
@testable import SSFSigner
@testable import SSFChainConnection
@testable import SSFStorageQueryKit

class XcmExtrinsicBuilderProtocolMock: XcmExtrinsicBuilderProtocol {

    //MARK: - buildReserveNativeTokenExtrinsicBuilderClosure

    var buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount = 0
    var buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCalled: Bool {
        return buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount > 0
    }
    var buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments: (version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath)?
    var buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations: [(version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath)] = []
    var buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue: ExtrinsicBuilderClosure!
    var buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure: ((XcmCallFactoryVersion, ChainModel, ChainModel, AccountId, BigUInt, BigUInt?, XcmCallPath) -> ExtrinsicBuilderClosure)?

    func buildReserveNativeTokenExtrinsicBuilderClosure(version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath) -> ExtrinsicBuilderClosure {
        buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount += 1
        buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments = (version: version, fromChainModel: fromChainModel, destChainModel: destChainModel, destAccountId: destAccountId, amount: amount, weightLimit: weightLimit, path: path)
        buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations.append((version: version, fromChainModel: fromChainModel, destChainModel: destChainModel, destAccountId: destAccountId, amount: amount, weightLimit: weightLimit, path: path))
        return buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure.map({ $0(version, fromChainModel, destChainModel, destAccountId, amount, weightLimit, path) }) ?? buildReserveNativeTokenExtrinsicBuilderClosureVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue
    }

    //MARK: - buildXTokensTransferExtrinsicBuilderClosure

    var buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount = 0
    var buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCalled: Bool {
        return buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount > 0
    }
    var buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments: (version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)?
    var buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations: [(version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)] = []
    var buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue: ExtrinsicBuilderClosure!
    var buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure: ((XcmCallFactoryVersion, AccountId?, CurrencyId, ChainModel, BigUInt, BigUInt, XcmCallPath) -> ExtrinsicBuilderClosure)?

    func buildXTokensTransferExtrinsicBuilderClosure(version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath) -> ExtrinsicBuilderClosure {
        buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount += 1
        buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments = (version: version, accountId: accountId, currencyId: currencyId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path)
        buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations.append((version: version, accountId: accountId, currencyId: currencyId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path))
        return buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure.map({ $0(version, accountId, currencyId, destChainModel, amount, weightLimit, path) }) ?? buildXTokensTransferExtrinsicBuilderClosureVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue
    }

    //MARK: - buildXTokensTransferMultiassetExtrinsicBuilderClosure

    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError: Error?
    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount = 0
    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCalled: Bool {
        return buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount > 0
    }
    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments: (assetSymbol: String, version: XcmCallFactoryVersion, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?)?
    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations: [(assetSymbol: String, version: XcmCallFactoryVersion, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?)] = []
    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue: ExtrinsicBuilderClosure!
    var buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure: ((String, XcmCallFactoryVersion, AccountId?, ChainModel, ChainModel, BigUInt, BigUInt, XcmCallPath, Bool?) throws -> ExtrinsicBuilderClosure)?

    func buildXTokensTransferMultiassetExtrinsicBuilderClosure(assetSymbol: String, version: XcmCallFactoryVersion, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?) throws -> ExtrinsicBuilderClosure {
        if let error = buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError {
            throw error
        }
        buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount += 1
        buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments = (assetSymbol: assetSymbol, version: version, accountId: accountId, fromChainModel: fromChainModel, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path, destWeightIsPrimitive: destWeightIsPrimitive)
        buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations.append((assetSymbol: assetSymbol, version: version, accountId: accountId, fromChainModel: fromChainModel, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path, destWeightIsPrimitive: destWeightIsPrimitive))
        return try buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure.map({ try $0(assetSymbol, version, accountId, fromChainModel, destChainModel, amount, weightLimit, path, destWeightIsPrimitive) }) ?? buildXTokensTransferMultiassetExtrinsicBuilderClosureAssetSymbolVersionAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue
    }

    //MARK: - buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosure

    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError: Error?
    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount = 0
    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCalled: Bool {
        return buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount > 0
    }
    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments: (fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)?
    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations: [(fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)] = []
    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue: ExtrinsicBuilderClosure!
    var buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure: ((ChainModel, XcmCallFactoryVersion, String, AccountId?, ChainModel, BigUInt, BigUInt, XcmCallPath) throws -> ExtrinsicBuilderClosure)?

    func buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosure(fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath) throws -> ExtrinsicBuilderClosure {
        if let error = buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError {
            throw error
        }
        buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount += 1
        buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments = (fromChainModel: fromChainModel, version: version, assetSymbol: assetSymbol, accountId: accountId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path)
        buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations.append((fromChainModel: fromChainModel, version: version, assetSymbol: assetSymbol, accountId: accountId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path))
        return try buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure.map({ try $0(fromChainModel, version, assetSymbol, accountId, destChainModel, amount, weightLimit, path) }) ?? buildPolkadotXcmLimitedReserveTransferAssetsExtrinsicBuilderClosureFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue
    }

    //MARK: - buildBridgeProxyBurn

    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathThrowableError: Error?
    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount = 0
    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCalled: Bool {
        return buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount > 0
    }
    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments: (fromChainModel: ChainModel, currencyId: String, destChainModel: ChainModel, accountId: AccountId?, amount: BigUInt, path: XcmCallPath)?
    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations: [(fromChainModel: ChainModel, currencyId: String, destChainModel: ChainModel, accountId: AccountId?, amount: BigUInt, path: XcmCallPath)] = []
    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReturnValue: ExtrinsicBuilderClosure!
    var buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathClosure: ((ChainModel, String, ChainModel, AccountId?, BigUInt, XcmCallPath) throws -> ExtrinsicBuilderClosure)?

    func buildBridgeProxyBurn(fromChainModel: ChainModel, currencyId: String, destChainModel: ChainModel, accountId: AccountId?, amount: BigUInt, path: XcmCallPath) throws -> ExtrinsicBuilderClosure {
        if let error = buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathThrowableError {
            throw error
        }
        buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount += 1
        buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments = (fromChainModel: fromChainModel, currencyId: currencyId, destChainModel: destChainModel, accountId: accountId, amount: amount, path: path)
        buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations.append((fromChainModel: fromChainModel, currencyId: currencyId, destChainModel: destChainModel, accountId: accountId, amount: amount, path: path))
        return try buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathClosure.map({ try $0(fromChainModel, currencyId, destChainModel, accountId, amount, path) }) ?? buildBridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReturnValue
    }

}
