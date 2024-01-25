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
    
    override func tearDown() {
        super.tearDown()
        service = nil
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
        // arrange
        signInProvider?._currentUser = TestData.user
        
        let googleDriveService = GTLRDriveServiceMock()
        googleDriveService.authorizer = TestData.user.fetcherAuthorizer
        service?.googleDriveService = googleDriveService
        googleDriveService.executeQueryReturnValue = GTLRServiceTicketMock()
        
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: {_ in })
        
        // assert
        XCTAssertNotNil(signInProvider)
        XCTAssertTrue(signInProvider?.signInWithPresentingHintClosureCalled ?? true)
        XCTAssertEqual(signInProvider?.signInWithPresentingHintClosureCallsCount, 1)
    }
    
    func testDeleteBackupAccount() {
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: { [weak self] _ in
            self?.service?.deleteBackupAccount(account: TestData.account, completion: { [weak self] result in
                let provider = self?.signInProvider
                let state = self?.isSuccess(result)
                
                // assert
                XCTAssertNotNil(provider)
                XCTAssertNotNil(state)
                XCTAssertTrue(provider?.signInWithPresentingHintClosureCalled ?? true)
                XCTAssertEqual(provider?.signInWithPresentingHintClosureCallsCount, 2)
                XCTAssertTrue(state ?? true)
            })
        })
    }
    
    func testGetBackupAccounts() {
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: { [weak self] _ in
            self?.service?.getBackupAccounts(completion: { result in
                let provider = self?.signInProvider
                
                // assert
                switch result {
                case .success(let accounts):
                    XCTAssertNotNil(provider)
                    XCTAssertTrue(provider?.signInWithPresentingHintClosureCalled ?? true)
                    XCTAssertEqual(provider?.signInWithPresentingHintClosureCallsCount, 2)
                    XCTAssertEqual(accounts.count, 1)
                    XCTAssertEqual(accounts.first?.address, TestData.account.address)
                case .failure(let error):
                    XCTFail("Get backup accounts test failed with error - \(error)")
                }
            })
        })
    }
    
    func testImportBackupAccount() {
        // act
        service?.saveBackupAccount(account: TestData.account, password: "1", completion: { [weak self] _ in
            self?.service?.importBackupAccount(account: TestData.account, password: "1", completion: { [weak self] result in
                let provider = self?.signInProvider
                
                // assert
                switch result {
                case .success(let account):
                    XCTAssertNotNil(provider)
                    XCTAssertTrue(provider?.signInWithPresentingHintClosureCalled ?? true)
                    XCTAssertEqual(provider?.signInWithPresentingHintClosureCallsCount, 2)
                    XCTAssertEqual(account.address, TestData.account.address)
                case .failure(let error):
                    XCTFail("Get backup accounts test failed with error - \(error)")
                }
            })
        })
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
    
    func isSuccess<T, E>(_ result: Result<T, E>) -> Bool {
        if case .success = result {
            return true
        } else {
            return false
        }
    }
}
