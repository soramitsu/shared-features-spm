import Foundation
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Drive
import SSFUtils

public enum FearlessCompatibilityError: Error {
    case cantRemoveExtensionBackup
    case backupNotFound
}

public protocol FearlessCompatibilityProtocol: CloudStorageServiceProtocol {
    func getFearlessBackupAccounts() async throws -> [OpenBackupAccount]
    func importBackup(account: OpenBackupAccount, password: String) async throws -> OpenBackupAccount
    func deleteBackup(account: OpenBackupAccount) async throws
}

extension CloudStorageService: FearlessCompatibilityProtocol {
    
    // MARK: - Public methods
    
    public func getFearlessBackupAccounts() async throws -> [OpenBackupAccount] {
        let mobileAccounts = try await getBackupAccountsAwait()
        let extensionAccounts = try await getBackupAccountForFearlessExtension()
        
        let filtredExtensionAccounts = extensionAccounts.filter { extensionAccount in
            !mobileAccounts.contains(where: { $0.address == extensionAccount.address })
        }
        let accounts = mobileAccounts + filtredExtensionAccounts
        return accounts
    }
    
    public func importBackup(
        account: OpenBackupAccount,
        password: String
    ) async throws -> OpenBackupAccount {
        do {
            let mobileAccount = try await importBackupAwait(account: account, password: password)
            return mobileAccount
        } catch {
            if let error = error as? CloudStorageServiceError {
                switch error {
                case .notFound:
                    let extensionAccount = try await executeExtension(account: account, password: password)
                    return extensionAccount
                case .incorectPassword, .incorectJson, .notAuthorized:
                    throw error
                }
            }
            throw error
        }
    }
    
    public func deleteBackup(account: OpenBackupAccount) async throws {
        let mobileAccounts = try await getBackupAccountsAwait()
        let extensionAccounts = try await getBackupAccountForFearlessExtension()
        
        if mobileAccounts.contains(where: { $0.address == account.address }) {
            try await withUnsafeThrowingContinuation { contuniation in
                self.deleteBackupAccount(account: account) { result in
                    switch result {
                    case .success:
                        contuniation.resume()
                    case .failure(let failure):
                        contuniation.resume(with: .failure(failure))
                    }
                }
            }
            return
        } else if extensionAccounts.contains(where: { $0.address == account.address }) {
            throw FearlessCompatibilityError.cantRemoveExtensionBackup
        }
        
        throw FearlessCompatibilityError.backupNotFound
    }
    
    // MARK: - Private methods
    
    private func getBackupAccountsAwait() async throws -> [OpenBackupAccount] {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.getBackupAccounts { result in
                continuation.resume(with: result)
            }
        })
    }
    
    private func importBackupAwait(
        account: OpenBackupAccount,
        password: String
    ) async throws -> OpenBackupAccount {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.importBackupAccount(
                account: account,
                password: password,
                completion: { result in
                    continuation.resume(with: result)
                }
            )
        })
    }
    
    private func executeExtension(
        account: OpenBackupAccount,
        password: String
    ) async throws -> OpenBackupAccount {
        let extensionAccounts = try await getAppDataFolder()
        
        guard
            let fileId = extensionAccounts.first(where: {
                $0.descriptionProperty?.contains(account.address) == true
            })?.identifier,
            let ethereumFileId = account.ethDerivationPath
        else {
            throw CloudStorageServiceError.notFound
        }
        
        let substrateData = try await execureQueryForMedia(withFileId: fileId)
        let ethereumData = try await execureQueryForMedia(withFileId: ethereumFileId)
        return try createOpenBackupAccount(
            address: account.address,
            password: password,
            substrateData: substrateData,
            ethereumData: ethereumData
        )
    }
    
    private func createOpenBackupAccount(
        address: String,
        password: String,
        substrateData: Data,
        ethereumData: Data
    ) throws -> OpenBackupAccount {
        let definition = try JSONDecoder().decode(KeystoreDefinition.self, from: substrateData)
        let info = try KeystoreInfoFactory().createInfo(from: definition)
        
        let substrateJson = String(data: substrateData, encoding: .utf8)
        let ethereumJson = String(data: ethereumData, encoding: .utf8)
        let json = OpenBackupAccount.Json(
            substrateJson: substrateJson,
            ethJson: ethereumJson
        )
        
        return OpenBackupAccount(
            name: info.meta?.name,
            address: address,
            passphrase: password,
            cryptoType: String(info.cryptoType.rawValue),
            backupAccountType: [.json],
            json: json
        )
    }

    private func getBackupAccountForFearlessExtension() async throws -> [OpenBackupAccount] {
        let signInState = await signInIfNeeded()
        guard signInState == .authorized else {
            throw CloudStorageServiceError.notAuthorized
        }
        
        let appDataFilderFiles = try await getAppDataFolder()
        let accounts: [OpenBackupAccount] = appDataFilderFiles.compactMap {
            guard
                let descriptionProperty = $0.descriptionProperty,
                descriptionProperty.contains("/") == true,
                let addressSubSequence = $0.descriptionProperty?.split(separator: "/").first,
                let ethereumJsonFileId = $0.descriptionProperty?.split(separator: "/").last
            else {
                return nil
            }
            return OpenBackupAccount(
                name: $0.name?.replacingOccurrences(of: ".json", with: ""),
                address: String(addressSubSequence),
                ethDerivationPath: String(ethereumJsonFileId)
            )
        }
        
        return accounts
    }
    
    private func execureQueryForMedia(withFileId: String) async throws -> Data {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: withFileId)
            self?.googleDriveService?.executeQuery(query, completionHandler: { (ticket, file, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                guard let data = (file as? GTLRDataObject)?.data else {
                    continuation.resume(throwing: CloudStorageServiceError.notFound)
                    return
                }
                continuation.resume(returning: data)
            })
        })
    }
    
    private func getAppDataFolder() async throws -> [GTLRDrive_File] {
        let signInState = await signInIfNeeded()
        guard signInState == .authorized else {
            throw CloudStorageServiceError.notAuthorized
        }

        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        query.fields = "files(id, name, description)"
        query.q = "'appDataFolder' in parents and mimeType != 'application/vnd.google-apps.folder'"
        
        return try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.googleDriveService?.executeQuery(query) { (ticket, results, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let files = (results as? GTLRDrive_FileList)?.files ?? []
                continuation.resume(returning: files)
            }
        })
    }
    
    private func signInIfNeeded() async -> CloudStorageAccountState {
        await withCheckedContinuation { [weak self] continuation in
            self?.signInIfNeeded(completion: { state in
                continuation.resume(returning: state)
            })
        }
    }
}
