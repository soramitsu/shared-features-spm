import Foundation

public final class QRPreinstalledWalletMatcher: QRMatcher {
    public init() {}

    public func match(code: String) -> QRMatcherType? {
        return .preinstalledWallet(code)
    }
}
