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

    // MARK: - reserveNativeToken

    public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount =
        0
    public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCalled: Bool {
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount >
            0
    }

    public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments: (
        version: XcmCallFactoryVersion,
        fromChainModel: ChainModel,
        destChainModel: ChainModel,
        destAccountId: AccountId,
        amount: BigUInt,
        weightLimit: BigUInt?,
        path: XcmCallPath
    )?
    public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations: [
        (
            version: XcmCallFactoryVersion,
            fromChainModel: ChainModel,
            destChainModel: ChainModel,
            destAccountId: AccountId,
            amount: BigUInt,
            weightLimit: BigUInt?,
            path: XcmCallPath
        )
    ] = []
    public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue: RuntimeCall<
        ReserveTransferAssetsCall
    >!
    public var reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure: (
        (
            XcmCallFactoryVersion,
            ChainModel,
            ChainModel,
            AccountId,
            BigUInt,
            BigUInt?,
            XcmCallPath
        ) -> RuntimeCall<ReserveTransferAssetsCall>
    )?

    public func reserveNativeToken(
        version: XcmCallFactoryVersion,
        fromChainModel: ChainModel,
        destChainModel: ChainModel,
        destAccountId: AccountId,
        amount: BigUInt,
        weightLimit: BigUInt?,
        path: XcmCallPath
    ) -> RuntimeCall<ReserveTransferAssetsCall> {
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathCallsCount +=
            1
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedArguments =
            (
                version: version,
                fromChainModel: fromChainModel,
                destChainModel: destChainModel,
                destAccountId: destAccountId,
                amount: amount,
                weightLimit: weightLimit,
                path: path
            )
        reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReceivedInvocations
            .append((
                version: version,
                fromChainModel: fromChainModel,
                destChainModel: destChainModel,
                destAccountId: destAccountId,
                amount: amount,
                weightLimit: weightLimit,
                path: path
            ))
        return reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathClosure
            .map { $0(
                version,
                fromChainModel,
                destChainModel,
                destAccountId,
                amount,
                weightLimit,
                path
            ) } ??
            reserveNativeTokenVersionFromChainModelDestChainModelDestAccountIdAmountWeightLimitPathReturnValue
    }

    // MARK: - xTokensTransfer

    public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount =
        0
    public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCalled: Bool {
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount > 0
    }

    public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments: (
        version: XcmCallFactoryVersion,
        accountId: AccountId?,
        currencyId: CurrencyId,
        destChainModel: ChainModel,
        amount: BigUInt,
        weightLimit: BigUInt,
        path: XcmCallPath
    )?
    public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations: [
        (
            version: XcmCallFactoryVersion,
            accountId: AccountId?,
            currencyId: CurrencyId,
            destChainModel: ChainModel,
            amount: BigUInt,
            weightLimit: BigUInt,
            path: XcmCallPath
        )
    ] = []
    public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue: RuntimeCall<
        XTokensTransferCall
    >!
    public var xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure: (
        (
            XcmCallFactoryVersion,
            AccountId?,
            CurrencyId,
            ChainModel,
            BigUInt,
            BigUInt,
            XcmCallPath
        ) -> RuntimeCall<XTokensTransferCall>
    )?

    public func xTokensTransfer(
        version: XcmCallFactoryVersion,
        accountId: AccountId?,
        currencyId: CurrencyId,
        destChainModel: ChainModel,
        amount: BigUInt,
        weightLimit: BigUInt,
        path: XcmCallPath
    ) -> RuntimeCall<XTokensTransferCall> {
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathCallsCount += 1
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedArguments =
            (
                version: version,
                accountId: accountId,
                currencyId: currencyId,
                destChainModel: destChainModel,
                amount: amount,
                weightLimit: weightLimit,
                path: path
            )
        xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReceivedInvocations
            .append((
                version: version,
                accountId: accountId,
                currencyId: currencyId,
                destChainModel: destChainModel,
                amount: amount,
                weightLimit: weightLimit,
                path: path
            ))
        return xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathClosure
            .map { $0(
                version,
                accountId,
                currencyId,
                destChainModel,
                amount,
                weightLimit,
                path
            ) } ??
            xTokensTransferVersionAccountIdCurrencyIdDestChainModelAmountWeightLimitPathReturnValue
    }

    // MARK: - xTokensTransferMultiasset

    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError: Error?
    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount =
        0
    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCalled: Bool {
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount >
            0
    }

    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments: (
        version: XcmCallFactoryVersion,
        assetSymbol: String,
        accountId: AccountId?,
        fromChainModel: ChainModel,
        destChainModel: ChainModel,
        amount: BigUInt,
        weightLimit: BigUInt,
        path: XcmCallPath,
        destWeightIsPrimitive: Bool?
    )?
    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations: [
        (
            version: XcmCallFactoryVersion,
            assetSymbol: String,
            accountId: AccountId?,
            fromChainModel: ChainModel,
            destChainModel: ChainModel,
            amount: BigUInt,
            weightLimit: BigUInt,
            path: XcmCallPath,
            destWeightIsPrimitive: Bool?
        )
    ] = []
    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue: RuntimeCall<
        XTokensTransferMultiassetCall
    >!
    public var xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure: (
        (
            XcmCallFactoryVersion,
            String,
            AccountId?,
            ChainModel,
            ChainModel,
            BigUInt,
            BigUInt,
            XcmCallPath,
            Bool?
        ) throws -> RuntimeCall<XTokensTransferMultiassetCall>
    )?

    public func xTokensTransferMultiasset(
        version: XcmCallFactoryVersion,
        assetSymbol: String,
        accountId: AccountId?,
        fromChainModel: ChainModel,
        destChainModel: ChainModel,
        amount: BigUInt,
        weightLimit: BigUInt,
        path: XcmCallPath,
        destWeightIsPrimitive: Bool?
    ) throws -> RuntimeCall<XTokensTransferMultiassetCall> {
        if let error =
            xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveThrowableError
        {
            throw error
        }
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveCallsCount +=
            1
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedArguments =
            (
                version: version,
                assetSymbol: assetSymbol,
                accountId: accountId,
                fromChainModel: fromChainModel,
                destChainModel: destChainModel,
                amount: amount,
                weightLimit: weightLimit,
                path: path,
                destWeightIsPrimitive: destWeightIsPrimitive
            )
        xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReceivedInvocations
            .append((
                version: version,
                assetSymbol: assetSymbol,
                accountId: accountId,
                fromChainModel: fromChainModel,
                destChainModel: destChainModel,
                amount: amount,
                weightLimit: weightLimit,
                path: path,
                destWeightIsPrimitive: destWeightIsPrimitive
            ))
        return try xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveClosure
            .map { try $0(
                version,
                assetSymbol,
                accountId,
                fromChainModel,
                destChainModel,
                amount,
                weightLimit,
                path,
                destWeightIsPrimitive
            ) } ??
            xTokensTransferMultiassetVersionAssetSymbolAccountIdFromChainModelDestChainModelAmountWeightLimitPathDestWeightIsPrimitiveReturnValue
    }

    // MARK: - polkadotXcmLimitedReserveTransferAssets

    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError: Error?
    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount =
        0
    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCalled: Bool {
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount >
            0
    }

    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments: (
        fromChainModel: ChainModel,
        version: XcmCallFactoryVersion,
        assetSymbol: String,
        accountId: AccountId?,
        destChainModel: ChainModel,
        amount: BigUInt,
        weightLimit: BigUInt,
        path: XcmCallPath
    )?
    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations: [
        (
            fromChainModel: ChainModel,
            version: XcmCallFactoryVersion,
            assetSymbol: String,
            accountId: AccountId?,
            destChainModel: ChainModel,
            amount: BigUInt,
            weightLimit: BigUInt,
            path: XcmCallPath
        )
    ] = []
    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue: RuntimeCall<
        ReserveTransferAssetsCall
    >!
    public var polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure: (
        (
            ChainModel,
            XcmCallFactoryVersion,
            String,
            AccountId?,
            ChainModel,
            BigUInt,
            BigUInt,
            XcmCallPath
        ) throws -> RuntimeCall<ReserveTransferAssetsCall>
    )?

    public func polkadotXcmLimitedReserveTransferAssets(
        fromChainModel: ChainModel,
        version: XcmCallFactoryVersion,
        assetSymbol: String,
        accountId: AccountId?,
        destChainModel: ChainModel,
        amount: BigUInt,
        weightLimit: BigUInt,
        path: XcmCallPath
    ) throws -> RuntimeCall<ReserveTransferAssetsCall> {
        if let error =
            polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathThrowableError
        {
            throw error
        }
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathCallsCount +=
            1
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedArguments =
            (
                fromChainModel: fromChainModel,
                version: version,
                assetSymbol: assetSymbol,
                accountId: accountId,
                destChainModel: destChainModel,
                amount: amount,
                weightLimit: weightLimit,
                path: path
            )
        polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReceivedInvocations
            .append((
                fromChainModel: fromChainModel,
                version: version,
                assetSymbol: assetSymbol,
                accountId: accountId,
                destChainModel: destChainModel,
                amount: amount,
                weightLimit: weightLimit,
                path: path
            ))
        return try polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathClosure
            .map { try $0(
                fromChainModel,
                version,
                assetSymbol,
                accountId,
                destChainModel,
                amount,
                weightLimit,
                path
            ) } ??
            polkadotXcmLimitedReserveTransferAssetsFromChainModelVersionAssetSymbolAccountIdDestChainModelAmountWeightLimitPathReturnValue
    }

    // MARK: - bridgeProxyBurn

    public var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount =
        0
    public var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCalled: Bool {
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount > 0
    }

    public var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments: (
        fromChainModel: ChainModel,
        currencyId: String,
        destChainModel: ChainModel,
        accountId: AccountId?,
        amount: BigUInt,
        path: XcmCallPath
    )?
    public var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations: [
        (
            fromChainModel: ChainModel,
            currencyId: String,
            destChainModel: ChainModel,
            accountId: AccountId?,
            amount: BigUInt,
            path: XcmCallPath
        )
    ] = []
    public var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReturnValue: RuntimeCall<
        BridgeProxyBurnCall
    >!
    public var bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathClosure: ((
        ChainModel,
        String,
        ChainModel,
        AccountId?,
        BigUInt,
        XcmCallPath
    ) -> RuntimeCall<BridgeProxyBurnCall>)?

    public func bridgeProxyBurn(
        fromChainModel: ChainModel,
        currencyId: String,
        destChainModel: ChainModel,
        accountId: AccountId?,
        amount: BigUInt,
        path: XcmCallPath
    ) -> RuntimeCall<BridgeProxyBurnCall> {
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathCallsCount += 1
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedArguments =
            (
                fromChainModel: fromChainModel,
                currencyId: currencyId,
                destChainModel: destChainModel,
                accountId: accountId,
                amount: amount,
                path: path
            )
        bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReceivedInvocations
            .append((
                fromChainModel: fromChainModel,
                currencyId: currencyId,
                destChainModel: destChainModel,
                accountId: accountId,
                amount: amount,
                path: path
            ))
        return bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathClosure
            .map { $0(
                fromChainModel,
                currencyId,
                destChainModel,
                accountId,
                amount,
                path
            ) } ??
            bridgeProxyBurnFromChainModelCurrencyIdDestChainModelAccountIdAmountPathReturnValue
    }
}
