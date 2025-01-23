import Foundation

final class TonQRDecoder: QRDecoder {
    func decode(data: Data) throws -> QRInfoType {
        guard 
            let string = String(data: data, encoding: .utf8),
            let url = URL(string: string),
            url.scheme == "ton",
            url.host == "transfer"
        else {
            throw QRDecoderError.brokenFormat
        }
        let address = url.lastPathComponent

        let tonAccountId = try? address.toAccountId(using: .ton(bounceable: true)).asTonAddress()
        guard tonAccountId != nil else {
            throw QRDecoderError.brokenFormat
        }

        return .cex(CexQRInfo(address: address))
    }
}
