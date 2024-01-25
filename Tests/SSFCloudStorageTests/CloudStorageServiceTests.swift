import XCTest
import GoogleAPIClientForRESTCore
import GoogleSignIn

@testable import SSFCloudStorage

final class CloudStorageServiceTests: XCTestCase {
    
    private enum CloudStorageServiceTestsError: Error {
        case noSignInProviderExists
    }

    var service: CloudStorageService?
    var signInProvider: GIDSignInMock?
    var delegate: UIViewController?
    var queue: DispatchQueueType?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let delegate = UIViewController()
        let signInProvider = GIDSignInMock.sharedInstance as? GIDSignInMock
        let queue = DispatchQueueMock()
        
        guard let signInProvider else { throw CloudStorageServiceTestsError.noSignInProviderExists }
        
        self.signInProvider = signInProvider
        self.delegate = delegate
        self.queue = queue
        
        service = CloudStorageService(uiDelegate: delegate,
                                      signInProvider: signInProvider,
                                      queue: queue)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        service = nil
        signInProvider?._currentUser = nil
        signInProvider?.signInWithPresentingHintClosureCallsCount = 0
        signInProvider = nil
        delegate = nil
        queue = nil
    }
    
    func testSignInIfNeeded() throws {
        // act
        service?.signInIfNeeded(completion: nil)

        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertTrue(signInProvider?.signInWithPresentingHintClosureCalled ?? true)
        XCTAssertEqual(signInProvider?.signInWithPresentingHintClosureCallsCount, 1)
    }
    
    func testSaveBackupAccount() {
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: {_ in })
        
        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertTrue(signInProvider?.signInWithPresentingHintClosureCalled ?? true)
        XCTAssertEqual(signInProvider?.signInWithPresentingHintClosureCallsCount, 1)
    }
    
    func testDeleteBackupAccount() {
        // arrange
        signInProvider?._currentUser = TestData.user
        
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: {_ in })
        service?.deleteBackupAccount(account: TestData.account, completion: {_ in })
        
        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertFalse(signInProvider?.signInWithPresentingHintClosureCalled ?? false)
        XCTAssertEqual(signInProvider?.signInWithPresentingHintClosureCallsCount, 0)
    }
    
    func testGetBackupAccounts() {
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: {_ in })
        service?.getBackupAccounts(completion:  {_ in })
        
        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertTrue(signInProvider?.signInWithPresentingHintClosureCalled ?? true)
        XCTAssertEqual(signInProvider?.signInWithPresentingHintClosureCallsCount, 2)
    }
    
    func testImportBackupAccount() {
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: {_ in })
        service?.importBackupAccount(account: TestData.account, password: "1", completion:  {_ in })
        
        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertTrue(signInProvider?.signInWithPresentingHintClosureCalled ?? true)
        XCTAssertEqual(signInProvider?.signInWithPresentingHintClosureCallsCount, 2)
    }
    
    func testDisconnect() {
        // act
        service?.disconnect()
        
        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertTrue(signInProvider?.disconnectCompletionCalled ?? true)
        XCTAssertTrue(signInProvider?.signOutCalled ?? true)
        XCTAssertEqual(signInProvider?.disconnectCompletionCallsCount, 1)
        XCTAssertEqual(signInProvider?.signOutCallsCount, 1)
    }
    
    func testFearlessImportBackupAccountWithError() async throws {
        signInProvider?._currentUser = TestData.user
        
        // act
        do {
            _ = try await service?.importBackup(account: TestData.account, password: "1")
        } catch {
            // Assert
            XCTAssertEqual(error.localizedDescription, "The request is missing a valid API key.")
        }
    }
    
    func testGetFearlessBackupAccountsWithError() async throws {
        signInProvider?._currentUser = TestData.user
        
        // act
        do {
            _ = try await service?.getFearlessBackupAccounts()
        } catch {
            // Assert
            XCTAssertEqual(error.localizedDescription, CloudStorageServiceError.notAuthorized.localizedDescription)
        }
    }
    
    func testFearlessDeleteAccountWithError() async throws {
        signInProvider?._currentUser = TestData.user
        
        // act
        do {
            _ = try await service?.deleteBackup(account: TestData.account)
        } catch {
            // Assert
            XCTAssertEqual(error.localizedDescription, CloudStorageServiceError.notAuthorized.localizedDescription)
        }
    }
}

extension CloudStorageServiceTests {
    enum TestData {
        static let user = GIDGoogleUser()
        static let account = OpenBackupAccount(name: "test",
                                               address: "cnVkoGs3rEMqLqY27c2nfVXJRGdzNJk2ns78DcqtppaSRe8qm",
                                               passphrase: "street firm worth record skin taste legend lobster magnet stove drive side",
                                               cryptoType: "XOR",
                                               substrateDerivationPath: "/path//substrate",
                                               ethDerivationPath: "/path//eth",
                                               backupAccountType: [.passphrase],
                                               json: OpenBackupAccount.Json(substrateJson: "0", ethJson: "1"),
                                               encryptedSeed: OpenBackupAccount.Seed(substrateSeed: "2", ethSeed: "3"))
    }
}
