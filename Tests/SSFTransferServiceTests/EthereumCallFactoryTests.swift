import XCTest
import SSFModels
import Web3
import SSFHelpers

@testable import SSFTransferService

final class EthereumCallFactoryTests: XCTestCase {
    
    private var callFactory: EthereumCallFactory?

    override func setUpWithError() throws {
        try super.setUpWithError()
        try setupCallFactory()
    }

    func testSignNative() async throws {
        let transfer = EthereumTransfer(amount: "1000000000000", receiver: "0xccb15402c89b730d930e2ec7e3a4acd7edf724d6")
        let signedTansaction = try await callFactory?.signNative(transfer: transfer)
        XCTAssertTrue(signedTansaction?.verifySignature() == true)
    }
    
    func testSignERC20() async throws {
        let transfer = EthereumTransfer(amount: "1000000000000", receiver: "0xccb15402c89b730d930e2ec7e3a4acd7edf724d6")
        let signedTansaction = try await callFactory?.signERC20(transfer: transfer)
        XCTAssertTrue(signedTansaction?.verifySignature() == true)
    }

    //MARK: - Private methods
    
    private func createERC20ChainAsset() -> ChainAsset {
        let chain = ChainModelGenerator.generate(chainId: "1", count: 1).first!
        let asset = ChainModelGenerator.generateAssetWithId(
            "0x6B175474E89094C44Da98b954EedeAC495271d0F",
            symbol: "dai",
            assetPresicion: 18,
            chainId: "1"
        )
        let chainAsset = ChainAsset(chain: chain, asset: asset)
        return chainAsset
    }
    
    private func setupEthereumService() -> EthereumService {
        let service = EthereumServiceMock()
        service.queryGasPriceReturnValue = EthereumQuantity(quantity: "1")
        service.checkChainSupportEip1559ReturnValue = true
        service.queryNonceEthereumAddressReturnValue = EthereumQuantity(quantity: "1")
        service.queryGasLimitCallReturnValue = EthereumQuantity(quantity: "1")
        service.queryGasLimitFromAmountTransferReturnValue = EthereumQuantity(quantity: "1")
        service.connection = Web3(rpcURL: "https//google.com").eth
        return service
    }
    
    private func setupCallFactory() throws {
        let secret = Data(hex: "0x85dedefd3fa46b486db7460be303aa3baa44ce1249c6e42e2731ffdf68a33068")
        let secretKey = try EthereumPrivateKey(privateKey: secret.bytes)
        let chainAsset = createERC20ChainAsset()
        let ethereumService = setupEthereumService()
        
        let callFactory: EthereumCallFactory = EthereumCallFactoryDefault(
            ethereumService: ethereumService,
            chainAsset: chainAsset,
            senderAddress: "0xccb15402c89b730d930e2ec7e3a4acd7edf724d6",
            privateKey: secretKey
        )
        self.callFactory = callFactory
    }
}
