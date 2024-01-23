import XCTest
import IrohaCrypto
import BigInt
import SSFUtils
import SSFModels
import SSFCrypto

@testable import SSFKeyPair

final class JsonCreatorTests: XCTestCase {
    
    private lazy var jsonCreator: JsonCreator = {
        JsonCreatorImpl()
    }()
    
    private lazy var keystoreExtractor = KeystoreExtractor()
    
    func testCreateJson() {
        // Act
        do {
            let result = try jsonCreator.createJson(strength: .entropy128,
                                                    walletName: "wallet",
                                                    password: "password",
                                                    cryptoType: .sr25519,
                                                    derivationPath: "",
                                                    isEthereumBased: false)
            
            // Assert
            XCTAssertNotNil(result.json)
            XCTAssertEqual(result.mnemonic.numberOfWords(), 12)
        } catch {
            XCTFail("Create json test failed with error - \(error)")
        }
    }
    
    func testSubsctrateJson() throws {
        let derivationPaths: [String] = [
            "",
            "//foo//boo",
            "//1231"
        ]
        
        try performJsonCreatorTest(ethereumBased: false,
                                   cryptoTypes: [.sr25519, .ed25519, .ecdsa],
                                   derivationPaths: derivationPaths
        )
    }
    
    func testEthereumBasedJson() throws {
        let derivationPaths: [String] = [
            "",
            "/0",
            "//0",
            "/12//3"
        ]
        
        try performJsonCreatorTest(ethereumBased: true,
                                   cryptoTypes: [.ecdsa],
                                   derivationPaths: derivationPaths
        )
    }
}

extension JsonCreatorTests {
    func performJsonCreatorTest(ethereumBased: Bool,
                                cryptoTypes: [CryptoType],
                                derivationPaths: [String]) throws {
        let passwords: [String] = ["", "password"]
        let strengths: [IRMnemonicStrength] = [
            .entropy128,
            .entropy160,
            .entropy192,
            .entropy224,
            .entropy256,
            .entropy288,
            .entropy320
        ]
        
        for strength in strengths {
            for password in passwords {
                for cryptoType in cryptoTypes {
                    for derivationPath in derivationPaths {
                        let expectedResult = try jsonCreator.createJson(
                            strength: strength,
                            walletName: "wallet",
                            password: password,
                            cryptoType: cryptoType,
                            derivationPath: derivationPath,
                            isEthereumBased: ethereumBased
                        )
                        
                        let derivedResult = try jsonCreator.deriveJson(
                            mnemonicWords: expectedResult.mnemonic.toString(),
                            walletName: "wallet",
                            password: password,
                            cryptoType: cryptoType,
                            derivationPath: derivationPath,
                            isEthereumBased: ethereumBased
                        )
                        
                        let expectedMnemonic = expectedResult.mnemonic
                        let derivedMnemonic = derivedResult.mnemonic
                        
                        let expectedDefinition = try JSONDecoder().decode(KeystoreDefinition.self, from: expectedResult.json)
                        let derivedDefinition = try JSONDecoder().decode(KeystoreDefinition.self, from: derivedResult.json)
                        
                        let expectedKeystoreData = try keystoreExtractor.extractFromDefinition(expectedDefinition, password: password)
                        let derivedKeystoreData = try keystoreExtractor.extractFromDefinition(derivedDefinition, password: password)
                        
                        XCTAssertEqual(expectedKeystoreData.publicKeyData.toHex(), derivedKeystoreData.publicKeyData.toHex())
                        XCTAssertEqual(expectedKeystoreData.secretKeyData.toHex(), derivedKeystoreData.secretKeyData.toHex())
                        
                        XCTAssertEqual(expectedMnemonic.toString(), derivedMnemonic.toString())
                        XCTAssertEqual(expectedMnemonic.entropy(), derivedMnemonic.entropy())
                    }
                }
            }
        }
    }
}

