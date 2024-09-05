import Foundation

public final class QRInfoMatcher: QRMatcher {
    private let decoder: QRDecoder

    public init(decoder: QRDecoder) {
        self.decoder = decoder
    }

    public func match(code: String) -> QRMatcherType? {
        guard let data = code.data(using: .utf8), let info = try? decoder.decode(data: data) else {
            return nil
        }

        return .qrInfo(info)
    }
}
