// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import SSFQRService

class QRInfoMock: QRInfo {
    var address: String {
        get { return underlyingAddress }
        set(value) { underlyingAddress = value }
    }
    var underlyingAddress: String!

}
