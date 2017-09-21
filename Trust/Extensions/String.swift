// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation

extension String {
    var hex: String {
        let data = self.data(using: .utf8)!
        return data.map{ String(format:"%02x", $0) }.joined()
    }
}

extension Data {
    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
