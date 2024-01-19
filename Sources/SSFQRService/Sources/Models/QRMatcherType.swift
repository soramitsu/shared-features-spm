import Foundation

public enum QRMatcherType {
    case qrInfo(QRInfoType)
    case uri(String)

    public var address: String? {
        switch self {
        case let .qrInfo(qRInfoType):
            switch qRInfoType {
            case let .sora(soraQRInfo):
                return soraQRInfo.address
            case let .cex(cexQRInfo):
                return cexQRInfo.address
            case let .bokoloCash(qrInfo):
                return qrInfo.address
            }
        case .uri:
            return nil
        }
    }

    public var qrInfo: QRInfoType? {
        switch self {
        case let .qrInfo(qRInfoType):
            return qRInfoType
        case .uri:
            return nil
        }
    }

    public var uri: String? {
        switch self {
        case .qrInfo:
            return nil
        case let .uri(uri):
            return uri
        }
    }
}
