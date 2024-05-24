import RobinHood
import SSFModels
import SSFNetwork
import XCTest

@testable import SSFIndexers

enum BaseHistoryServiceError: Error {
    case fileNotFound(name: String)
}

class BaseHistoryServiceTestCase: XCTestCase {
    var networkWorker: NetworkWorker?
    var historyService: HistoryService?

    func chainAsset(
        blockExplorerType: BlockExplorerType,
        assetSymbol: String,
        precision: UInt16,
        ethereumType: EthereumAssetType?,
        contractaddress: String?
    ) -> ChainAsset {
        let historyBlockExplorer = ChainModel.BlockExplorer(
            type: blockExplorerType.rawValue,
            url: URL(string: "https://www.google.com")!,
            apiKey: ""
        )
        let externalApi = ChainModel.ExternalApiSet(history: historyBlockExplorer)

        let asset = AssetModel(
            id: contractaddress ?? "2",
            name: "asset name",
            symbol: assetSymbol,
            precision: precision,
            isUtility: true,
            isNative: true,
            type: .normal,
            ethereumType: ethereumType
        )

        let chain = ChainModel(
            rank: nil,
            disabled: false,
            chainId: "1",
            parentId: nil,
            paraId: nil,
            name: "",
            assets: [asset],
            xcm: nil,
            nodes: [],
            addressPrefix: 1,
            types: nil,
            icon: nil,
            options: [],
            externalApi: externalApi,
            selectedNode: nil,
            customNodes: nil,
            iosMinAppVersion: nil
        )

        let chainAsset = ChainAsset(
            chain: chain,
            asset: asset
        )
        return chainAsset
    }

    func getResponse<T: Decodable>(file name: String) throws -> T {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw BaseHistoryServiceError.fileNotFound(name: name)
        }
        let data = try Data(contentsOf: url)
        let jsonDecoder = JSONDecoder()
        let value = try jsonDecoder.decode(T.self, from: data)
        return value
    }
}
