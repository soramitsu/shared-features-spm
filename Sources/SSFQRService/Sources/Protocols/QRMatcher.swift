import Foundation

//sourcery: AutoMockable
public protocol QRMatcher {
    func match(code: String) -> QRMatcherType?
}
