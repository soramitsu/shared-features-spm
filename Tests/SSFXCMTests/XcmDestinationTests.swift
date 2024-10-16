import SSFModels
import XCTest

@testable import SSFXCM

final class XcmDestinationTests: XCTestCase {
    func testDetermineChainType() throws {
        // act
        let chainType = try XcmChainType.determineChainType(for: TestData.chain)

        // assert
        XCTAssertEqual(chainType.hashValue, XcmChainType.nativeParachain.hashValue)
    }

    func testDetermineChainTypeWithError() throws {
        // act
        XCTAssertThrowsError(
            try XcmChainType
                .determineChainType(for: TestData.errorChain)
        ) { error in
            // assert
            XCTAssertEqual(
                error.localizedDescription,
                XcmError.invalidParachainRange.localizedDescription
            )
        }
    }
}

extension XcmDestinationTests {
    enum TestData {
        static let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("test")
            .appendingPathExtension("json")

        static let chain = ChainModel(
            disabled: false,
            chainId: "1",
            name: "test",
            tokens: ChainRemoteTokens(
                type: .config,
                whitelist: nil,
                utilityId: nil,
                tokens: []
            ),
            xcm: nil,
            nodes: Set([ChainNodeModel(
                url: TestData.url,
                name: "test",
                apikey: nil
            )]),
            icon: nil,
            iosMinAppVersion: nil,
            properties: ChainProperties(
                addressPrefix: "0",
                rank: "1"
            ),
            identityChain: nil
        )

        static let errorChain = ChainModel(
            disabled: false,
            chainId: "1",
            name: "test",
            tokens: ChainRemoteTokens(
                type: .config,
                whitelist: nil,
                utilityId: nil,
                tokens: []
            ),
            xcm: nil,
            nodes: Set([ChainNodeModel(
                url: TestData.url,
                name: "test",
                apikey: nil
            )]),
            icon: nil,
            iosMinAppVersion: nil,
            properties: ChainProperties(
                addressPrefix: "1",
                rank: "1"
            ),
            identityChain: nil
        )
    }
}
