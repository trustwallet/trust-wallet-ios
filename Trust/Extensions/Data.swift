// Copyright DApps Platform Inc. All rights reserved.

import Foundation

extension Data {
    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var hexEncoded: String {
        return "0x" + self.hex
    }

    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}
