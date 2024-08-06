import XCTest

@testable import SSFXCM

final class XcmAssemblyTests: XCTestCase {
    func testCreateExtrincisServices() throws {
        // act
        let service = try XcmAssembly.createExtrincisServices(
            fromChainData: TestData.fromChainData,
            sourceConfig: XcmConfig.shared, 
            chainRegistry: nil
        )

        // assert
        XCTAssertNotNil(service)
    }
}

extension XcmAssemblyTests {
    enum TestData {
        static let fromChainData = XcmAssembly.FromChainData(
            chainId: "1",
            cryptoType: .ed25519,
            chainMetadata: nil,
            accountId: Data(),
            signingWrapperData: .init(
                publicKeyData: Data(),
                secretKeyData: Data()
            )
        )
    }
}
