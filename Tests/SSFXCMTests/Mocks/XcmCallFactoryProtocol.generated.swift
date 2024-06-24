// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import BigInt
@testable import RobinHood
@testable import SSFChainConnection
@testable import SSFChainRegistry
@testable import SSFExtrinsicKit
@testable import SSFModels
@testable import SSFNetwork
@testable import SSFRuntimeCodingService
@testable import SSFSigner
@testable import SSFStorageQueryKit
@testable import SSFUtils
@testable import SSFXCM

public class XcmCallFactoryProtocolMock: XcmCallFactoryProtocol {
    public init() {}

        //MARK: - reserveNativeToken

        public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount = 0
        public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCalled: Bool {
            return reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount > 0
        }
        public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments: (version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath)?
        public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations: [(version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath)] = []
        public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue: RuntimeCall<ReserveTransferAssetsCall>!
        public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure: ((XcmCallFactoryVersion, ChainModel, ChainModel, AccountId, BigUInt, BigUInt?, XcmCallPath) -> RuntimeCall<ReserveTransferAssetsCall>)?

        public func reserveNativeToken(version: XcmCallFactoryVersion, fromChainModel: ChainModel, destChainModel: ChainModel, destAccountId: AccountId, amount: BigUInt, weightLimit: BigUInt?, path: XcmCallPath) -> RuntimeCall<ReserveTransferAssetsCall> {
            reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount += 1
            reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments = (version: version, fromChainModel: fromChainModel, destChainModel: destChainModel, destAccountId: destAccountId, amount: amount, weightLimit: weightLimit, path: path)
            reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations.append((version: version, fromChainModel: fromChainModel, destChainModel: destChainModel, destAccountId: destAccountId, amount: amount, weightLimit: weightLimit, path: path))
            return reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure.map({ $0(version, fromChainModel, destChainModel, destAccountId, amount, weightLimit, path) }) ?? reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue
        }

        //MARK: - xTokensTransfer

        public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount = 0
        public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCalled: Bool {
            return xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount > 0
        }
        public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments: (version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)?
        public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations: [(version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)] = []
        public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue: RuntimeCall<XTokensTransferCall>!
        public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure: ((XcmCallFactoryVersion, AccountId?, CurrencyId, ChainModel, BigUInt, BigUInt, XcmCallPath) -> RuntimeCall<XTokensTransferCall>)?

        public func xTokensTransfer(version: XcmCallFactoryVersion, accountId: AccountId?, currencyId: CurrencyId, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath) -> RuntimeCall<XTokensTransferCall> {
            xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount += 1
            xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments = (version: version, accountId: accountId, currencyId: currencyId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path)
            xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations.append((version: version, accountId: accountId, currencyId: currencyId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path))
            return xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure.map({ $0(version, accountId, currencyId, destChainModel, amount, weightLimit, path) }) ?? xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue
        }

        //MARK: - xTokensTransferMultiasset

        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError: Error?
        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount = 0
        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCalled: Bool {
            return xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount > 0
        }
        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments: (version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?)?
        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations: [(version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?)] = []
        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue: RuntimeCall<XTokensTransferMultiassetCall>!
        public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure: ((XcmCallFactoryVersion, String, AccountId?, ChainModel, ChainModel, BigUInt, BigUInt, XcmCallPath, Bool?) throws -> RuntimeCall<XTokensTransferMultiassetCall>)?

        public func xTokensTransferMultiasset(version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, fromChainModel: ChainModel, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath, destWeightIsPrimitive: Bool?) throws -> RuntimeCall<XTokensTransferMultiassetCall> {
            if let error = xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError {
                throw error
            }
            xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount += 1
            xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments = (version: version, assetSymbol: assetSymbol, accountId: accountId, fromChainModel: fromChainModel, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path, destWeightIsPrimitive: destWeightIsPrimitive)
            xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations.append((version: version, assetSymbol: assetSymbol, accountId: accountId, fromChainModel: fromChainModel, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path, destWeightIsPrimitive: destWeightIsPrimitive))
            return try xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure.map({ try $0(version, assetSymbol, accountId, fromChainModel, destChainModel, amount, weightLimit, path, destWeightIsPrimitive) }) ?? xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue
        }

        //MARK: - polkadotXcmLimitedReserveTransferAssets

        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError: Error?
        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount = 0
        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCalled: Bool {
            return polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount > 0
        }
        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments: (fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)?
        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations: [(fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath)] = []
        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue: RuntimeCall<ReserveTransferAssetsCall>!
        public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure: ((ChainModel, XcmCallFactoryVersion, String, AccountId?, ChainModel, BigUInt, BigUInt, XcmCallPath) throws -> RuntimeCall<ReserveTransferAssetsCall>)?

        public func polkadotXcmLimitedReserveTransferAssets(fromChainModel: ChainModel, version: XcmCallFactoryVersion, assetSymbol: String, accountId: AccountId?, destChainModel: ChainModel, amount: BigUInt, weightLimit: BigUInt, path: XcmCallPath) throws -> RuntimeCall<ReserveTransferAssetsCall> {
            if let error = polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError {
                throw error
            }
            polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount += 1
            polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments = (fromChainModel: fromChainModel, version: version, assetSymbol: assetSymbol, accountId: accountId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path)
            polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations.append((fromChainModel: fromChainModel, version: version, assetSymbol: assetSymbol, accountId: accountId, destChainModel: destChainModel, amount: amount, weightLimit: weightLimit, path: path))
            return try polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure.map({ try $0(fromChainModel, version, assetSymbol, accountId, destChainModel, amount, weightLimit, path) }) ?? polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue
        }

        //MARK: - bridgeProxyBurn

        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathThrowableError: Error?
        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathCallsCount = 0
        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathCalled: Bool {
            return bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathCallsCount > 0
        }
        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments: (currencyId: String, destChainModel: ChainModel, accountId: AccountId, amount: BigUInt, path: XcmCallPath)?
        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations: [(currencyId: String, destChainModel: ChainModel, accountId: AccountId, amount: BigUInt, path: XcmCallPath)] = []
        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathReturnValue: RuntimeCall<BridgeProxyBurnCall>!
        public var bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathClosure: ((String, ChainModel, AccountId, BigUInt, XcmCallPath) throws -> RuntimeCall<BridgeProxyBurnCall>)?

        public func bridgeProxyBurn(currencyId: String, destChainModel: ChainModel, accountId: AccountId, amount: BigUInt, path: XcmCallPath) throws -> RuntimeCall<BridgeProxyBurnCall> {
            if let error = bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathThrowableError {
                throw error
            }
            bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathCallsCount += 1
            bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments = (currencyId: currencyId, destChainModel: destChainModel, accountId: accountId, amount: amount, path: path)
            bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations.append((currencyId: currencyId, destChainModel: destChainModel, accountId: accountId, amount: amount, path: path))
            return try bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathClosure.map({ try $0(currencyId, destChainModel, accountId, amount, path) }) ?? bridgeProxyBurnCurrencyIdDestChainModelAccountIdAmountPathReturnValue
        }

        //MARK: - soraBridgeAppBurn

        public var soraBridgeAppBurnCurrencyIdAccountIdAmountPathCallsCount = 0
        public var soraBridgeAppBurnCurrencyIdAccountIdAmountPathCalled: Bool {
            return soraBridgeAppBurnCurrencyIdAccountIdAmountPathCallsCount > 0
        }
        public var soraBridgeAppBurnCurrencyIdAccountIdAmountPathReceivedArguments: (currencyId: String?, accountId: AccountId, amount: BigUInt, path: XcmCallPath)?
        public var soraBridgeAppBurnCurrencyIdAccountIdAmountPathReceivedInvocations: [(currencyId: String?, accountId: AccountId, amount: BigUInt, path: XcmCallPath)] = []
        public var soraBridgeAppBurnCurrencyIdAccountIdAmountPathReturnValue: RuntimeCall<LiberlandBridgeProxyBurnCall>!
        public var soraBridgeAppBurnCurrencyIdAccountIdAmountPathClosure: ((String?, AccountId, BigUInt, XcmCallPath) -> RuntimeCall<LiberlandBridgeProxyBurnCall>)?

        public func soraBridgeAppBurn(currencyId: String?, accountId: AccountId, amount: BigUInt, path: XcmCallPath) -> RuntimeCall<LiberlandBridgeProxyBurnCall> {
            soraBridgeAppBurnCurrencyIdAccountIdAmountPathCallsCount += 1
            soraBridgeAppBurnCurrencyIdAccountIdAmountPathReceivedArguments = (currencyId: currencyId, accountId: accountId, amount: amount, path: path)
            soraBridgeAppBurnCurrencyIdAccountIdAmountPathReceivedInvocations.append((currencyId: currencyId, accountId: accountId, amount: amount, path: path))
            return soraBridgeAppBurnCurrencyIdAccountIdAmountPathClosure.map({ $0(currencyId, accountId, amount, path) }) ?? soraBridgeAppBurnCurrencyIdAccountIdAmountPathReturnValue
        }

    }
