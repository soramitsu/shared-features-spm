import Foundation

public struct OpenBackupAccount: Codable {
    
    public enum BackupAccountType: String, Codable {
        case passphrase
        case json
        case seed
    }
    
    public struct Json: Codable {
        public var substrateJson: String?
        public var ethJson: String?
        
        public init(substrateJson: String? = nil, ethJson: String? = nil) {
            self.substrateJson = substrateJson
            self.ethJson = ethJson
        }
    }
    
    public struct Seed: Codable {
        public var substrateSeed: String?
        public var ethSeed: String?
        
        public init(substrateSeed: String? = nil, ethSeed: String? = nil) {
            self.substrateSeed = substrateSeed
            self.ethSeed = ethSeed
        }
    }
    
    public var name: String?
    public var address: String
    public var cryptoType: String?
    public var substrateDerivationPath: String?
    public var ethDerivationPath: String?
    
    public var backupAccountType: [BackupAccountType]?
    
    public var passphrase: String?
    public var json: Json?
    public var encryptedSeed: Seed?
    
    public init(
        name: String? = nil,
        address: String,
        passphrase: String? = nil,
        cryptoType: String? = nil,
        substrateDerivationPath: String? = nil,
        ethDerivationPath: String? = nil,
        backupAccountType: [BackupAccountType]? = nil,
        json: Json? = nil,
        encryptedSeed: Seed? = nil
    ) {
        self.name = name
        self.address = address
        self.passphrase = passphrase
        self.substrateDerivationPath = substrateDerivationPath
        self.ethDerivationPath = ethDerivationPath
        self.cryptoType = cryptoType
        self.backupAccountType = backupAccountType
        self.json = json
        self.encryptedSeed = encryptedSeed
    }
}
