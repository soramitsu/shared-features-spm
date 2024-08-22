import Foundation

public final class TonConnectMatcherImpl: QRMatcher {
    public init() {}

    public func match(code: String) -> QRMatcherType? {
        if let deeplink = try? parseTonConnectDeeplink(string: code) {
          return deeplink
        }
        if let universalLink = try? parseTonConnectUniversalLink(string: code) {
          return universalLink
        }
        return nil
    }
    
    // MARK: - Private methods
    
    private func parseTonConnectDeeplink(string: String) throws -> QRMatcherType? {
        guard
            let url = URL(string: string),
            let scheme = url.scheme
        else {
            return nil
        }
        switch scheme {
        case "tc":
            return .tonConnect(string)
        default:
            return nil
        }
    }
    
    private func parseTonConnectUniversalLink(string: String) throws -> QRMatcherType? {
        guard
            let url = URL(string: string),
            let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: true
            )
        else {
            return nil
        }
        switch url.path {
        case "/ton-connect":
            var tcComponents = URLComponents()
            tcComponents.scheme = "tc"
            tcComponents.queryItems = components.queryItems
            guard let string = tcComponents.string else {
                return nil
            }
            return .tonConnect(string)
        default:
            return nil
        }
    }
}
