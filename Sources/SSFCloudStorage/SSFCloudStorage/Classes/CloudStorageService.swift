import Foundation
import GoogleSignIn
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Drive
import TweetNacl
import IrohaCrypto
import SSFModels
import SSFUtils

public struct KeystoreConstants {
    public static let nonceLength = 24
    public static let encryptionKeyLength = 32
}

public protocol CloudStorageServiceProtocol: AnyObject {
    var isUserAuthorized: Bool { get }
    func signInIfNeeded(completion: ((CloudStorageAccountState) -> Void)?)
    func getBackupAccounts(completion: @escaping (Result<[OpenBackupAccount], Error>) -> Void)
    func saveBackupAccount(account: OpenBackupAccount, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteBackupAccount(account: OpenBackupAccount, completion: @escaping (Result<Void, Error>) -> Void)
    func importBackupAccount(account: OpenBackupAccount, password: String, completion: @escaping (Result<OpenBackupAccount, Error>) -> Void)
    func disconnect()
}

public enum CloudStorageAccountState {
    case authorized
    case notAuthorized
}

protocol GoogleDriveServiceProtocol: AnyObject {
    var googleDriveService: GTLRDriveService? { get }
}

public class CloudStorageService: NSObject, GoogleDriveServiceProtocol {
    public var isUserAuthorized: Bool { singInProvider.currentUser != nil }
    internal var googleDriveService: GTLRDriveService?

    private let singInProvider = GIDSignIn.sharedInstance
    private weak var uiDelegate: UIViewController?

    public init(uiDelegate: UIViewController) {
        self.uiDelegate = uiDelegate
        super.init()
    }
    
    private func createFile(from account: OpenBackupAccount, password: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(account.address)")
            .appendingPathExtension("json")
        
        let encodedPassphrase = try createEncriptedData(with: password, message: account.passphrase)
        let encodedSubstrateDerivationPath = try createEncriptedData(with: password, message: account.substrateDerivationPath)
        let encodedEthDerivationPath = try createEncriptedData(with: password, message: account.ethDerivationPath)
        let encodedSubstrateSeed = try createEncriptedData(with: password, message: account.encryptedSeed?.substrateSeed)
        let encodedEthSeed = try createEncriptedData(with: password, message: account.encryptedSeed?.ethSeed)
        
        let encryptedSeed = OpenBackupAccount.Seed(
            substrateSeed: encodedSubstrateSeed?.toHex(),
            ethSeed: encodedEthSeed?.toHex()
        )
        
        let ecryptedBackupAccount = EcryptedBackupAccount(
            name: account.name ?? "",
            address: account.address,
            encryptedMnemonicPhrase: encodedPassphrase?.toHex(),
            encryptedSubstrateDerivationPath: encodedSubstrateDerivationPath?.toHex(),
            encryptedEthDerivationPath: encodedEthDerivationPath?.toHex(),
            cryptoType: account.cryptoType,
            backupAccountType: account.backupAccountType.map { $0.map { $0.rawValue }},
            json: account.json,
            encryptedSeed: encryptedSeed
        )
        
        let data = try JSONEncoder().encode(ecryptedBackupAccount)
        try data.write(to: url)
        
        return url
    }
    
    private func getDecrypted(from message: String?, password: String) throws -> String? {
        guard let message = message else {
            return nil
        }
        guard let passwordData = password.data(using: .utf8) else {
            throw CloudStorageServiceError.incorectPassword
        }

        let data = try Data(hexStringSSF: message)
        
        let scryptParameters = try ScryptParameters(data: data)
        
        let encryptionKey = try IRScryptKeyDeriviation()
            .deriveKey(from: passwordData,
                       salt: scryptParameters.salt,
                       scryptN: UInt(scryptParameters.scryptN),
                       scryptP: UInt(scryptParameters.scryptP),
                       scryptR: UInt(scryptParameters.scryptR),
                       length: UInt(KeystoreConstants.encryptionKeyLength))

        let nonceStart = ScryptParameters.encodedLength
        let nonceEnd = ScryptParameters.encodedLength + KeystoreConstants.nonceLength
        let encnonce = Data(data[nonceStart..<nonceEnd])
        let encryptedData = Data(data[nonceEnd...])

        let dencodedData = try NaclSecretBox.open(box: encryptedData, nonce: encnonce, key: encryptionKey)
        return String(decoding: dencodedData, as: UTF8.self)
    }
    
    private func createEncriptedData(with password: String, message: String?) throws -> Data? {
        guard let message = message else {
            return nil
        }
        guard let passwordData = password.data(using: .utf8) else {
            throw CloudStorageServiceError.incorectPassword
        }
        
        let scryptParameters = try ScryptParameters()

        let encryptionKey = try IRScryptKeyDeriviation()
            .deriveKey(from: passwordData,
                       salt: scryptParameters.salt,
                       scryptN: UInt(scryptParameters.scryptN),
                       scryptP: UInt(scryptParameters.scryptP),
                       scryptR: UInt(scryptParameters.scryptR),
                       length: UInt(KeystoreConstants.encryptionKeyLength))

        let messageUtf8 = Data(message.utf8)
        let nonce = try Data.generateRandomBytes(of: KeystoreConstants.nonceLength)
        let encrypted = try NaclSecretBox.secretBox(message: messageUtf8, nonce: nonce, key: encryptionKey)
        return scryptParameters.encode() + nonce + encrypted
    }
    
    private func getParentFolder(completion: @escaping ((Result<String, Error>) -> Void)) {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        query.q = "name = 'backupFolder'"

        googleDriveService?.executeQuery(query) { [weak self] (ticket, results, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            let files = (results as? GTLRDrive_FileList)?.files ?? []
            if files.isEmpty {
                self?.createBackupFolder(completion: completion)
                return
            }

            let folderId: String = (results as? GTLRDrive_FileList)?.files?.first?.identifier ?? ""
            completion(.success(folderId))
        }
    }
    
    private func createBackupFolder(completion: @escaping ((Result<String, Error>) -> Void)) {
        let file = GTLRDrive_File()
        file.name = "backupFolder"
        file.parents = ["appDataFolder"]
        file.mimeType = "application/vnd.google-apps.folder"
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)
        query.fields = "id"
        
        googleDriveService?.executeQuery(query, completionHandler: { (ticket, file, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let fileId = (file as? GTLRDrive_File)?.identifier ?? ""
            completion(.success(fileId))
        })
    }

}

// MARK: - CloudStorageServiceProtocol

extension CloudStorageService: CloudStorageServiceProtocol {
    public func signInIfNeeded(completion: ((CloudStorageAccountState) -> Void)?) {
        guard let uiDelegate = uiDelegate else {
            completion?(.notAuthorized)
            return
        }

        if let user = singInProvider.currentUser {
            let service = GTLRDriveService()
            service.authorizer = user.fetcherAuthorizer
            self.googleDriveService = service
            completion?(.authorized)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.singInProvider.signIn(withPresenting: uiDelegate, hint: nil, additionalScopes: [kGTLRAuthScopeDriveAppdata])  { result, error in
                if error != nil {
                    completion?(.notAuthorized)
                    return
                }

                let service = GTLRDriveService()
                service.authorizer = result?.user.fetcherAuthorizer
                self?.googleDriveService = service
                completion?(.authorized)
            }
        }
    }
    
    public func getBackupAccounts(completion: @escaping (Result<[OpenBackupAccount], Error>) -> Void) {
        signInIfNeeded { [weak self] state in
            guard state == .authorized else {
                completion(.failure(CloudStorageServiceError.notAuthorized))
                return
            }
            
            self?.getParentFolder(completion: { [weak self] result in
                guard case .success(let folderId) = result else {
                    completion(.failure(CloudStorageServiceError.notAuthorized))
                    return
                }

                let query = GTLRDriveQuery_FilesList.query()
                query.spaces = "appDataFolder"
                query.q = "'\(folderId)' in parents"
                query.fields = "files(id, name, description)"
                
                self?.googleDriveService?.executeQuery(query) { (ticket, results, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    let files: [GTLRDrive_File] = (results as? GTLRDrive_FileList)?.files ?? []
                    let accounts = files.map {
                        OpenBackupAccount(name: $0.descriptionProperty,
                                          address: String($0.name?.split(separator: ".").first ?? ""))
                    }
                    completion(.success(accounts))
                }
            })
        }
    }
    
    public func saveBackupAccount(account: OpenBackupAccount, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let fileUrl = try? createFile(from: account, password: password), let data = try? Data(contentsOf: fileUrl) else { return }
        
        signInIfNeeded { [weak self] state in
            guard state == .authorized else {
                completion(.failure(CloudStorageServiceError.notAuthorized))
                return
            }

            self?.getParentFolder(completion: { [weak self] result in
                guard case .success(let folderId) = result else {
                    completion(.failure(CloudStorageServiceError.notAuthorized))
                    return
                }
                
                let file = GTLRDrive_File()
                file.name = "\(account.address).json"
                file.descriptionProperty = account.name
                file.parents = ["\(folderId)"]
                
                let params = GTLRUploadParameters(data: data, mimeType: "application/json")
                params.shouldUploadWithSingleRequest = true
                
                let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: params)
                query.fields = "id"
                
                self?.googleDriveService?.executeQuery(query, completionHandler: { (ticket, file, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(()))
                })
            })
        }
    }
                                  
    
    public func importBackupAccount(account: OpenBackupAccount, password: String, completion: @escaping (Result<OpenBackupAccount, Error>) -> Void) {
        signInIfNeeded { [weak self] state in
            guard state == .authorized else {
                completion(.failure(CloudStorageServiceError.notAuthorized))
                return
            }
            
            let query = GTLRDriveQuery_FilesList.query()
            query.spaces = "appDataFolder"
            
            self?.googleDriveService?.executeQuery(query) { [weak self] (ticket, results, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let fileId = (results as? GTLRDrive_FileList)?.files?.first(where: { $0.name?.contains(account.address) ?? false })?.identifier else {
                    completion(.failure(CloudStorageServiceError.notFound))
                    return
                }
                
                let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
                self?.googleDriveService?.executeQuery(query) { [weak self] (ticket, file, error) in
                    guard let data = (file as? GTLRDataObject)?.data else {
                        completion(.failure(CloudStorageServiceError.notFound))
                        return
                    }
                    guard let account = try? JSONDecoder().decode(EcryptedBackupAccount.self, from: data) else {
                        completion(.failure(CloudStorageServiceError.incorectJson))
                        return
                    }
                    
                    let passphrase = try? self?.getDecrypted(from: account.encryptedMnemonicPhrase, password: password)
                    let substrateDerivationPath = try? self?.getDecrypted(from: account.encryptedSubstrateDerivationPath, password: password)
                    
                    var ethDerivationPath: String?

                    if let path = account.encryptedEthDerivationPath, !path.isEmpty {
                        guard let ethPath = try? self?.getDecrypted(from: path, password: password) else {
                            completion(.failure(CloudStorageServiceError.incorectPassword))
                            return
                        }
                        ethDerivationPath = ethPath
                    }
                    
                    let encryptedSeed = account.encryptedSeed
                    let substrateSeed = try? self?.getDecrypted(from: encryptedSeed?.substrateSeed, password: password)
                    let ethereumSeed = try? self?.getDecrypted(from: encryptedSeed?.ethSeed, password: password)
                    
                    let decodedAccount = OpenBackupAccount(
                        name: account.name,
                        address: account.address,
                        passphrase: passphrase,
                        cryptoType: account.cryptoType,
                        substrateDerivationPath: substrateDerivationPath,
                        ethDerivationPath: ethDerivationPath,
                        backupAccountType: account.backupAccountType?.compactMap { OpenBackupAccount.BackupAccountType(rawValue: $0) },
                        json: OpenBackupAccount.Json(substrateJson: account.json?.substrateJson, ethJson: account.json?.ethJson),
                        encryptedSeed: OpenBackupAccount.Seed(substrateSeed: substrateSeed, ethSeed: ethereumSeed)
                    )
                    completion(.success(decodedAccount))
                }
            }
        }
    }
    
    public func deleteBackupAccount(account: OpenBackupAccount, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        
        signInIfNeeded { [weak self] state in
            guard state == .authorized else {
                completion(.failure(CloudStorageServiceError.notAuthorized))
                return
            }

            self?.googleDriveService?.executeQuery(query) { [weak self] (ticket, results, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let fileId = (results as? GTLRDrive_FileList)?.files?.first(where: { file in
                    file.name == "\(account.address).json"
                })?.identifier else {
                    completion(.failure(CloudStorageServiceError.notFound))
                    return
                }
                self?.googleDriveService?.executeQuery(GTLRDriveQuery_FilesDelete.query(withFileId: fileId)) { (ticket, nilFile, error) in
                    guard let error = error else {
                        completion(.success(()))
                        return
                    }
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func disconnect() {
        singInProvider.signOut()
        singInProvider.disconnect()
    }
}
