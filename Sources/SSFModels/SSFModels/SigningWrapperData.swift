import Foundation

public struct SigningWrapperData: Equatable {
    public let publicKeyData: Data
    public let secretKeyData: Data

    public init(publicKeyData: Data, secretKeyData: Data) {
        self.publicKeyData = publicKeyData
        self.secretKeyData = secretKeyData
    }
}
