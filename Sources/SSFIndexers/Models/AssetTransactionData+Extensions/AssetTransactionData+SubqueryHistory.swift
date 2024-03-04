import Foundation
import BigInt
import SSFCrypto
import SSFModels

extension AssetTransactionData {
    static func createTransaction(
        from item: SubqueryHistoryElement,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        if let transfer = item.transfer {
            return createTransaction(
                from: item,
                transfer: transfer,
                address: address,
                chainAsset: chainAsset
            )
        }

        if let reward = item.reward {
            return createTransaction(
                from: item,
                reward: reward,
                address: address,
                chainAsset: chainAsset
            )
        }

        if let extrinsic = item.extrinsic {
            return createTransaction(
                from: item,
                extrinsic: extrinsic,
                asset: chainAsset.asset
            )
        }

        return AssetTransactionData(
            transactionId: item.identifier,
            status: .pending,
            assetId: chainAsset.asset.id,
            peerId: nil,
            peerFirstName: nil,
            peerLastName: nil,
            peerName: nil,
            details: nil,
            amount: nil,
            fees: [],
            timestamp: Int64(item.timestamp),
            type: "UNKNOWN",
            reason: nil,
            context: nil
        )
    }

    private static func createTransaction(
        from item: SubqueryHistoryElement,
        transfer: SubqueryTransfer,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        let status: AssetTransactionStatus = transfer.success ? .commited : .rejected
        let peerAddress = transfer.sender == address ? transfer.receiver : transfer.sender
        let accountId = try? AddressFactory.accountId(
            from: peerAddress,
            chain: chainAsset.chain
        )
        let peerId = accountId?.toHex() ?? peerAddress
        let amount = SubstrateAmountDecimal(
            string: transfer.amount,
            precision: chainAsset.asset.precision
        )

        let fee = AssetTransactionFee(
            identifier: chainAsset.asset.id,
            assetId: chainAsset.asset.id,
            amount: SubstrateAmountDecimal(
                string: transfer.fee,
                precision: chainAsset.asset.precision
            ),
            context: nil
        )

        let type = transfer.sender == address
        ? TransactionType.outgoing
        : TransactionType.incoming

        return AssetTransactionData(
            transactionId: item.identifier,
            status: status,
            assetId: chainAsset.asset.id,
            peerId: peerId,
            peerFirstName: nil,
            peerLastName: nil,
            peerName: peerAddress,
            details: nil,
            amount: amount,
            fees: [fee],
            timestamp: Int64(item.timestamp),
            type: type.rawValue,
            reason: nil,
            context: nil
        )
    }

    private static func createTransaction(
        from item: SubqueryHistoryElement,
        reward: SubqueryRewardOrSlash,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        let status: AssetTransactionStatus = .commited
        let amount = SubstrateAmountDecimal(
            string: reward.amount,
            precision: chainAsset.asset.precision
        )
        let type = reward.isReward ? TransactionType.reward.rawValue : TransactionType.slash.rawValue
        let accountId = try? AddressFactory.accountId(
            from: address,
            chain: chainAsset.chain
        )
        let peerId = accountId?.toHex() ?? address

        return AssetTransactionData(
            transactionId: item.identifier,
            status: status,
            assetId: chainAsset.asset.id,
            peerId: peerId,
            peerFirstName: reward.validator,
            peerLastName: nil,
            peerName: type,
            details: "#\(reward.era ?? 0)",
            amount: amount,
            fees: [],
            timestamp: Int64(item.timestamp),
            type: type,
            reason: item.identifier,
            context: nil
        )
    }

    static func createTransaction(
        from item: SubqueryHistoryElement,
        extrinsic: SubqueryExtrinsic,
        asset: AssetModel
    ) -> AssetTransactionData {
        let amount = SubstrateAmountDecimal(
            string: extrinsic.fee,
            precision: asset.precision
        )
        let status: AssetTransactionStatus = extrinsic.success ? .commited : .rejected
        
        return AssetTransactionData(
            transactionId: item.identifier,
            status: status,
            assetId: asset.id,
            peerId: item.address,
            peerFirstName: extrinsic.module,
            peerLastName: extrinsic.call,
            peerName: "\(extrinsic.module) \(extrinsic.call)",
            details: nil,
            amount: amount,
            fees: [],
            timestamp: Int64(item.timestamp),
            type: TransactionType.extrinsic.rawValue,
            reason: extrinsic.hash,
            context: nil
        )
    }

    static func createTransaction(
        from item: TransactionHistoryItem,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        if item.isTransfer {
            return createLocalTransfer(
                from: item,
                address: address,
                chainAsset: chainAsset
            )
        } else {
            return createLocalExtrinsic(
                from: item,
                address: address,
                chainAsset: chainAsset
            )
        }
    }

    private static func createLocalTransfer(
        from item: TransactionHistoryItem,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        let peerAddress = (item.sender == address ? item.receiver : item.sender) ?? item.sender
        let accountId = try? AddressFactory.accountId(
            from: peerAddress,
            chain: chainAsset.chain
        )
        let peerId = accountId?.toHex() ?? peerAddress

        let fee = AssetTransactionFee(
            identifier: chainAsset.asset.id,
            assetId: chainAsset.asset.id,
            amount: SubstrateAmountDecimal(
                string: item.fee,
                precision: chainAsset.asset.precision
            ),
            context: nil
        )

        let type = item.sender == address
        ? TransactionType.outgoing
        : TransactionType.incoming

        return AssetTransactionData(
            transactionId: item.txHash,
            status: item.status.walletValue,
            assetId: chainAsset.asset.id,
            peerId: peerId,
            peerFirstName: nil,
            peerLastName: nil,
            peerName: peerAddress,
            details: nil,
            amount: SubstrateAmountDecimal(
                string: item.value,
                precision: chainAsset.asset.precision
            ),
            fees: [fee],
            timestamp: item.timestamp,
            type: type.rawValue,
            reason: nil,
            context: nil
        )
    }

    private static func createLocalExtrinsic(
        from item: TransactionHistoryItem,
        address: String,
        chainAsset: ChainAsset
    ) -> AssetTransactionData {
        let amount = SubstrateAmountDecimal(
            string: item.fee,
            precision: chainAsset.asset.precision
        )

        let accountId = try? AddressFactory.accountId(
            from: address,
            chain: chainAsset.chain
        )

        let peerId = accountId?.toHex() ?? address

        return AssetTransactionData(
            transactionId: item.identifier,
            status: item.status.walletValue,
            assetId: chainAsset.asset.id,
            peerId: peerId,
            peerFirstName: item.moduleName,
            peerLastName: item.callName,
            peerName: "\(item.moduleName) \(item.callName)",
            details: nil,
            amount: amount,
            fees: [],
            timestamp: item.timestamp,
            type: TransactionType.extrinsic.rawValue,
            reason: nil,
            context: nil
        )
    }
}
