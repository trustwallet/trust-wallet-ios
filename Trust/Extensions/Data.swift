// Copyright SIX DAY LLC. All rights reserved.

import Foundation

extension Data {
    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var hexEncoded: String {
        return "0x" + self.hex
    }

    init(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = i*2
            let bytes = hex[j..<j+2]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            }
        }
        self = data
    }
}
