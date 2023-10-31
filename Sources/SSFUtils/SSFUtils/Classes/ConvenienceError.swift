import Foundation

public struct ConvenienceError: Error {
    let error: String
    
    public init(error: String) {
        self.error = error
    }
}

extension ConvenienceError: LocalizedError {
    public var errorDescription: String? {
        NSLocalizedString(error, comment: "")
    }
}

extension ConvenienceError: ErrorContentConvertible {
    func toErrorContent(for _: Locale?) -> ErrorContent {
        ErrorContent(title: error, message: "")
    }
}
