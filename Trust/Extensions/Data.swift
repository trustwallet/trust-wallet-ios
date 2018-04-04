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
        var data = Data(capacity: hex.count/2)
        let stringBytes = hex.data(using: .ascii, allowLossyConversion: true)?.bytes ?? Array(hex.utf8)
        for i in stride(from: 0, to: stringBytes.count, by: 2) {
            if let high = Data.value(of: stringBytes[i]), let low = Data.value(of: stringBytes[i + 1]) {
                data.append((high << 4) | low)
            }
        }
        self = data
    }

    private static func value(of nibble: UInt8) -> UInt8? {
        switch nibble {
        case UInt8(ascii: "0") ... UInt8(ascii: "9"):
            return nibble - UInt8(ascii: "0")
        case UInt8(ascii: "a") ... UInt8(ascii: "f"):
            return 10 + nibble - UInt8(ascii: "a")
        case UInt8(ascii: "A") ... UInt8(ascii: "F"):
            return 10 + nibble - UInt8(ascii: "A")
        default:
            return nil
        }
    }

    init?(fromHexEncodedString string: String) {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch u {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }

    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}
