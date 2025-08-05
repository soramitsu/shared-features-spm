//
//  Pkcs8Coder.swift
//  fearless
//
//  Created by Nikolai Zhukov on 04.08.2025.
//  Copyright © 2025 Soramitsu. All rights reserved.
//

import Foundation

enum Pkcs8DecodeError: Error {
    case incorrectChecksum
}

final class Pkcs8ChecksumCoder {
    static let pkcs8Header = Data([48, 83, 2, 1, 1, 48, 5, 6, 3, 43, 101, 112, 4, 34, 4, 32])
    static let pkcs8Divider = Data([161, 35, 3, 33, 0])

    static func decode(data: Data) throws -> (privateKey: Data, publicKey: Data) {
        do {
            return try decodeDefaultFormat(data: data)
        } catch {
            return try decodeFearlessFormat(data: data)
        }
    }

    private static func decodeDefaultFormat(data: Data) throws -> (privateKey: Data, publicKey: Data) {
        let parts = data.split(by: pkcs8Header)
        guard parts.count == 2 else { throw Pkcs8DecodeError.incorrectChecksum }

        let rest = parts[1]
        let secrets = rest.split(by: pkcs8Divider)
        guard secrets.count == 2 else { throw Pkcs8DecodeError.incorrectChecksum }

        return (privateKey: secrets[0], publicKey: secrets[1])
    }

    private static func decodeFearlessFormat(data: Data) throws -> (privateKey: Data, publicKey: Data) {
        let privateKeyMarker = Data([0x04, 0x22, 0x04, 0x20])
        guard let privateKeyRange = data.range(of: privateKeyMarker) else {
            throw Pkcs8DecodeError.incorrectChecksum
        }

        let privateKeyStart = privateKeyRange.upperBound
        guard privateKeyStart + 32 <= data.count else {
            throw Pkcs8DecodeError.incorrectChecksum
        }

        let privateKey = data.subdata(in: privateKeyStart..<privateKeyStart + 32)

        let publicKeyMarker = Data([0xA1, 0x23, 0x03, 0x21, 0x00])
        guard let publicKeyRange = data.range(of: publicKeyMarker) else {
            throw Pkcs8DecodeError.incorrectChecksum
        }

        let publicKeyStart = publicKeyRange.upperBound
        guard publicKeyStart + 32 <= data.count else {
            throw Pkcs8DecodeError.incorrectChecksum
        }

        let publicKey = data.subdata(in: publicKeyStart..<publicKeyStart + 32)

        let expandedSecret = privateKey + Data(repeating: 0, count: 32)

        return (privateKey: expandedSecret, publicKey: publicKey)
    }

    static func encode(_ values: [Data]) -> Data {
        guard !values.isEmpty else { return Data() }

        return values.enumerated().reduce(pkcs8Header) { acc, pair in
            let (index, element) = pair
            return acc + (index > 0 ? pkcs8Divider + element : element)
        }
    }
}

extension Data {
    func split(by separator: Data) -> [Data] {
        var result: [Data] = []
        var start = startIndex

        while let range = self[start...].range(of: separator) {
            result.append(self[start..<range.lowerBound])
            start = range.upperBound
        }

        result.append(self[start...])

        return result
    }
}
