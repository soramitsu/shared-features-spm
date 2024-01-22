import XCTest

@testable import SSFQRService

final class ExtractQrCodeTests: XCTestCase {

    var qrService: QRService?

    override func setUpWithError() throws {
        qrService = QRServiceDefault()
    }

    override func tearDownWithError() throws {
        qrService = nil
    }

    func testQRImage() async throws {

        // arrange
        let address = "5GLDeyxgNzsnm4NeSHZd9imbSMaV2RUPGRSkchxsUqSbfBpu"
        let qrSize = CGSize(width: 100.0, height: 120.0)

        // act
        let image = try await qrService?.generate(with: .address(address), qrSize: qrSize)

        // assert
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size, qrSize)
        // TODO: ?
    }

    func testGenerateAddress() async throws {
        
        // arrange
        let address = "5GLDeyxgNzsnm4NeSHZd9imbSMaV2RUPGRSkchxsUqSbfBpu"
        let qrSize = CGSize(width: 500, height: 500)

        // act
        let image = try await qrService?.generate(with: .address(address), qrSize: qrSize)

        // assert
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size, qrSize)
        let qrMatcher = try qrService?.extractQrCode(from: image!)
        XCTAssertNotNil(qrMatcher)
        XCTAssertEqual(qrMatcher?.address, address)
    }

    func testGenerateSoraQRInfo() async throws {

        // arrange
        let rawPublicKey = "0xbcc5ecf679ebd776866a04c212a4ec5dc45cefab57d7aa858c389844e212693f"
        let qrSize = CGSize(width: 500, height: 500)
        let qrInfo = SoraQRInfo(
            address: "cnVkoGs3rEMqLqY27c2nfVXJRGdzNJk2ns78DcqtppaSRe8qm",
            rawPublicKey: try Data(hexStringSSF: rawPublicKey),
            username: "UserName",
            assetId: "0x0200000000000000000000000000000000000000000000000000000000000000",
            amount: "123"
        )

        // act
        let image = try await qrService?.generate(with: .addressInfo(qrInfo), qrSize: qrSize)

        // assert
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size, qrSize)
        let qrMatcher = try qrService?.extractQrCode(from: image!)
        XCTAssertNotNil(qrMatcher)
        XCTAssertEqual(qrMatcher?.address, qrInfo.address)

        switch qrMatcher!.qrInfo {
        case .sora(let qrInfoResult):
            XCTAssertEqual(qrInfoResult, qrInfo)
        case .none, .some :
            XCTAssert(true)
        }
    }

    // TODO: add mock
//    func testGenerate() async throws {
//
//        // arrange
//        let qrSize = CGSize(width: 500, height: 500)
//        let qrInfo = BokoloCashQRInfo(
//            address: "cnVkoGs3rEMqLqY27c2nfVXJRGdzNJk2ns78DcqtppaSRe8qm",
//            assetId: "0x0200000000000000000000000000000000000000000000000000000000000000",
//            transactionAmount: "123"
//        )
//
//        // act
//        let image = try await qrService?.generate(with: .addressInfo(qrInfo), qrSize: qrSize)
//
//        // assert
//        XCTAssertNotNil(image)
//        XCTAssertEqual(image?.size, qrSize)
//        let qrMatcher = try qrService?.extractQrCode(from: image!)
//        XCTAssertNotNil(qrMatcher)
//        XCTAssertEqual(qrMatcher?.address, qrInfo.address)
//
//        switch qrMatcher!.qrInfo {
//        case .bokoloCash(let qrInfoResult):
//            XCTAssertEqual(qrInfoResult, qrInfo)
//        case .none, .some :
//            XCTAssert(true)
//        }
//    }
}
