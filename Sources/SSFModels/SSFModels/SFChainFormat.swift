import Foundation

public enum ChainFormatError: Error {
    case wrongFormat
}

public enum ChainFormat {
    case ethereum
    case substrate(_ prefix: UInt16)
    case ton(bounceable: Bool)
}
