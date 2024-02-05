import Foundation

@testable import SSFCloudStorage

final class EncryptionServiceMock: EncryptionServiceProtocol {
    
    //MARK: - getDecrypted
    
    var getDecryptedCallsCount: Int = 0
    var getDecryptedCalled: Bool {
        return getDecryptedCallsCount > 0
    }
    var getDecryptedReceivedArguments: (message: String?, password: String)?
    var getDecryptedReceivedInvocations: [(message: String?, password: String)] = []
    var getDecryptedReturnValue: String?
    
    func getDecrypted(from message: String?, password: String) throws -> String? {
        getDecryptedCallsCount += 1
        getDecryptedReceivedArguments = (message: message, password: password)
        getDecryptedReceivedInvocations.append((message: message, password: password))
        return getDecryptedReturnValue ?? message
    }
    
    // MARK: - createEncryptedData
    
    var createEncryptedDataCallsCount: Int = 0
    var createEncryptedDataCalled: Bool {
        return createEncryptedDataCallsCount > 0
    }
    var createEncryptedDataReceivedArguments: (password: String, message: String?)?
    var createEncryptedDataReceivedInvocations: [(password: String, message: String?)] = []
    var createEncryptedDataReturnValue: Data?
    
    func createEncryptedData(with password: String, message: String?) throws -> Data? {
        createEncryptedDataCallsCount += 1
        createEncryptedDataReceivedArguments = (password: password, message: message)
        createEncryptedDataReceivedInvocations.append((password: password, message: message))
        return createEncryptedDataReturnValue
    }
}
