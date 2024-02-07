import XCTest
import BigInt
import SSFModels

@testable import SSFXCM

final class BridgeProxyBurnCallTests: XCTestCase {
    
    func testBridgeProxyBurnCallInit() {
        // arrange
        let amount: BigUInt = BigUInt()
        let networkId: BridgeTypesGenericNetworkId = .evm(amount)
        let assetId: SoraAssetId = SoraAssetId(wrappedValue: "1")
        let recipient: BridgeTypesGenericAccount = .root
        
        // act
        let call = BridgeProxyBurnCall(networkId: networkId,
                                       assetId: assetId,
                                       recipient: recipient,
                                       amount: amount)
        
        // assert
        XCTAssertEqual(call.amount, amount)
        XCTAssertEqual(call.networkId, networkId)
        XCTAssertEqual(call.assetId, assetId)
        XCTAssertEqual(call.recipient, recipient)
    }
    
    func testBridgeTypesGenericNetworkIdInit() {
        // act
        let networkId = BridgeTypesGenericNetworkId(from: TestData.chain)

        // assert
        XCTAssertNotNil(networkId)
        XCTAssertEqual(networkId, .sub(TestData.subNetworkId))
    }
    
    func testBridgeTypesSubNetworkIdInit() {
        // act
        let subNetworkId = BridgeTypesSubNetworkId(from: TestData.chain)
        
        // assert
        XCTAssertNotNil(subNetworkId)
        XCTAssertEqual(subNetworkId, TestData.subNetworkId)
    }
    
    func testSoraAssetIdInit() {
        // arrange
        let value = "1"
        
        // act
        let soraAssetId = SoraAssetId(wrappedValue: value)

        // assert
        XCTAssertNotNil(soraAssetId)
        XCTAssertEqual(soraAssetId.value, value)
    }
    
    func testArrayCodableInit() {
        // arrange
        let value = "1"
        
        // act
        let arrayCodable = ArrayCodable(wrappedValue: value)
        
        // assert
        XCTAssertNotNil(arrayCodable)
        XCTAssertEqual(arrayCodable.wrappedValue, value)
    }
    
}

extension BridgeProxyBurnCallTests {
    enum TestData {
        static let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("test")
            .appendingPathExtension("json")
        
        static let chain = ChainModel(rank: 1,
                                      disabled: false,
                                      chainId: "1",
                                      paraId: "1",
                                      name: "test",
                                      xcm: nil,
                                      nodes: Set([ChainNodeModel(url: TestData.url, name: "test")]),
                                      addressPrefix: 1,
                                      icon: nil,
                                      iosMinAppVersion: nil)
        
        static let subNetworkId = BridgeTypesSubNetworkId(from: chain)
    }
}
