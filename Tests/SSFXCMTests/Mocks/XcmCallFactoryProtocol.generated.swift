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

class XcmCallFactoryProtocolMock: XcmCallFactoryProtocol {

    //MARK: - reserveNativeToken

    var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount = 0
    var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCalled: Bool {
        return reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount > 0
    }
    var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments: (version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath)?
    var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations: [(version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath)] = []
    var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue: RuntimeCall<ReserveTransferAssetsCall>!
    var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure: ((XcmCallFactoryVersion, ChainModel, ChainModel, AccountId, BigUInt, BigUInt?, XcmCallPath) -> RuntimeCall<ReserveTransferAssetsCall>)?

    func reserveNativeToken(version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath) -> RuntimeCall<ReserveTransferAssetsCall> {
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount += 1
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments = (version: version, fromChainModel: fromChainModel, destChainModel: destChainModel, destAccountId: destAccountId, amount: amount, weightLimit: weightLimit, path: path)
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations.append((version: version, fromChainModel: fromChainModel, destChainModel: destChainModel, destAccountId: destAccountId, amount: amount, weightLimit: weightLimit, path: path))
        return reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure.map({ $0(version, fromChainModel, destChainModel, destAccountId, amount, weightLimit, path) }) ?? reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue
    }

    //MARK: - xTokensTransfer

    var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount = 0
    var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCalled: Bool {
        return xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount > 0
    }
    var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments: (version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)?
    var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations: [(version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)] = []
    var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue: RuntimeCall<XTokensTransferCall>!
    var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure: ((XcmCallFactoryVersion, AccountId?, CurrencyId, ChainModel, BigUInt, BigUInt, XcmCallPath) -> RuntimeCall<XTokensTransferCall>)?

    func xTokensTransfer(version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath) -> RuntimeCall<XTokensTransferCall> {
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount += 1
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments = (version: version, accountId: accountId, currencyId: currencyId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path)
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations.append((version: version, accountId: accountId, currencyId: currencyId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path))
        return xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure.map({ $0(version, accountId, currencyId, destChainModel, amount, weightLimit, path) }) ?? xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue
    }

    //MARK: - xTokensTransferMultiasset

    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError: Error?
    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount = 0
    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCalled: Bool {
        return xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount > 0
    }
    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments: (version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?)?
    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations: [(version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?)] = []
    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue: RuntimeCall<XTokensTransferMultiassetCall>!
    var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure: ((XcmCallFactoryVersion, String, AccountId?, ChainModel, ChainModel, BigUInt, BigUInt, XcmCallPath, Bool?) throws -> RuntimeCall<XTokensTransferMultiassetCall>)?

    func xTokensTransferMultiasset(version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?) throws -> RuntimeCall<XTokensTransferMultiassetCall> {
        if let error = xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError {
            throw error
        }
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount += 1
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments = (version: version, assetSymbol: assetSymbol, accountId: accountId, fromChainModel: fromChainModel, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path, destWeightIsPrimitive: destWeightIsPrimitive)
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations.append((version: version, assetSymbol: assetSymbol, accountId: accountId, fromChainModel: fromChainModel, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path, destWeightIsPrimitive: destWeightIsPrimitive))
        return try xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure.map({ try $0(version, assetSymbol, accountId, fromChainModel, destChainModel, amount, weightLimit, path, destWeightIsPrimitive) }) ?? xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue
    }

    //MARK: - polkadotXcmLimitedReserveTransferAssets

    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError: Error?
    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount = 0
    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCalled: Bool {
        return polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount > 0
    }
    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments: (fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)?
    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations: [(fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)] = []
    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue: RuntimeCall<ReserveTransferAssetsCall>!
    var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure: ((ChainModel, XcmCallFactoryVersion, String, AccountId?, ChainModel, BigUInt, BigUInt, XcmCallPath) throws -> RuntimeCall<ReserveTransferAssetsCall>)?

    func polkadotXcmLimitedReserveTransferAssets(fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath) throws -> RuntimeCall<ReserveTransferAssetsCall> {
        if let error = polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError {
            throw error
        }
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount += 1
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments = (fromChainModel: fromChainModel, version: version, assetSymbol: assetSymbol, accountId: accountId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path)
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations.append((fromChainModel: fromChainModel, version: version, assetSymbol: assetSymbol, accountId: accountId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path))
        return try polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure.map({ try $0(fromChainModel, version, assetSymbol, accountId, destChainModel, amount, weightLimit, path) }) ?? polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue
    }

    //MARK: - bridgeProxyBurn

    var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount = 0
    var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCalled: Bool {
        return bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount > 0
    }
    var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments: (fromChainModel: ChainModel, currencyId: String, destChainModel: ChainModel, accountId: AccountId?, amount: BigUInt, path: XcmCallPath)?
    var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations: [(fromChainModel: ChainModel, currencyId: String, destChainModel: ChainModel, accountId: AccountId?, amount: BigUInt, path: XcmCallPath)] = []
    var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReturnValue: RuntimeCall<BridgeProxyBurnCall>!
    var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathClosure: ((ChainModel, String, ChainModel, AccountId?, BigUInt, XcmCallPath) -> RuntimeCall<BridgeProxyBurnCall>)?

    func bridgeProxyBurn(fromChainModel: ChainModel, currencyId: String, destChainModel: ChainModel, accountId: AccountId?, amount: BigUInt, path: XcmCallPath) -> RuntimeCall<BridgeProxyBurnCall> {
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount += 1
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments = (fromChainModel: fromChainModel, currencyId: currencyId, destChainModel: destChainModel, accountId: accountId, amount: amount, path: path)
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations.append((fromChainModel: fromChainModel, currencyId: currencyId, destChainModel: destChainModel, accountId: accountId, amount: amount, path: path))
        return bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathClosure.map({ $0(fromChainModel, currencyId, destChainModel, accountId, amount, path) }) ?? bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReturnValue
    }

}
