// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

/// Implementation of Ethereum's RLP encoding.
///
/// - SeeAlso: https://github.com/ethereum/wiki/wiki/RLP
public struct RLP {
    /// Encodes an element as RLP data.
    ///
    /// - Returns: Encoded data or `nil` if the element type is not supported.
    public static func encode(_ element: Any) -> Data? {
        switch element {
        case let string as String:
            return encodeString(string)
        case let list as [Any]:
            return encodeList(list)
        case let number as Int:
            return encodeInt(number)
        case let bigint as BigInt:
            return encodeBigInt(bigint)
        case let biguint as BigUInt:
            return encodeBigUInt(biguint)
        case let data as Data:
            return encodeData(data)
        default:
            return nil
        }
    }

    static func encodeString(_ string: String) -> Data? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        return encodeData(data)
    }

    static func encodeInt(_ number: Int) -> Data? {
        guard number >= 0 else {
            return nil // RLP cannot encode negative numbers
        }
        let uint = UInt(bitPattern: number)
        return encodeUInt(uint)
    }

    static func encodeUInt(_ number: UInt) -> Data? {
        let biguint = BigUInt(number)
        return encode(biguint)
    }

    static func encodeBigInt(_ number: BigInt) -> Data? {
        guard number.sign == .plus else {
            return nil // RLP cannot encode negative BigInts
        }
        return encodeBigUInt(number.magnitude)
    }

    static func encodeBigUInt(_ number: BigUInt) -> Data? {
        let encoded = number.serialize()
        if encoded.isEmpty {
            return Data(bytes: [0x80])
        }
        return encodeData(encoded)
    }

    static func encodeData(_ data: Data) -> Data {
        if data.count == 1 && data[0] <= 0x7f {
            // Fits in single byte, no header
            return data
        }

        var encoded = encodeHeader(size: UInt64(data.count), smallTag: 0x80, largeTag: 0xb7)
        encoded.append(data)
        return encoded
    }

    static func encodeList(_ elements: [Any]) -> Data? {
        var encodedData = Data()
        for el in elements {
            guard let encoded = encode(el) else {
                return nil
            }
            encodedData.append(encoded)
        }

        var encoded = encodeHeader(size: UInt64(encodedData.count), smallTag: 0xc0, largeTag: 0xf7)
        encoded.append(encodedData)
        return encoded
    }

    static func encodeHeader(size: UInt64, smallTag: UInt8, largeTag: UInt8) -> Data {
        if size < 56 {
            return Data([smallTag + UInt8(size)])
        }

        let sizeData = putint(size)
        var encoded = Data()
        encoded.append(largeTag + UInt8(sizeData.count))
        encoded.append(contentsOf: sizeData)
        return encoded
    }

    /// Returns the representation of an integer using the least number of bytes needed.
    static func putint(_ i: UInt64) -> Data {
        switch i {
        case 0 ..< (1 << 8):
            return Data([UInt8(i)])
        case 0 ..< (1 << 16):
            return Data([
                UInt8(i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        case 0 ..< (1 << 24):
            return Data([
                UInt8(i >> 16),
                UInt8(truncatingIfNeeded: i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        case 0 ..< (1 << 32):
            return Data([
                UInt8(i >> 24),
                UInt8(truncatingIfNeeded: i >> 16),
                UInt8(truncatingIfNeeded: i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        case 0 ..< (1 << 40):
            return Data([
                UInt8(i >> 32),
                UInt8(truncatingIfNeeded: i >> 24),
                UInt8(truncatingIfNeeded: i >> 16),
                UInt8(truncatingIfNeeded: i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        case 0 ..< (1 << 48):
            return Data([
                UInt8(i >> 40),
                UInt8(truncatingIfNeeded: i >> 32),
                UInt8(truncatingIfNeeded: i >> 24),
                UInt8(truncatingIfNeeded: i >> 16),
                UInt8(truncatingIfNeeded: i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        case 0 ..< (1 << 56):
            return Data([
                UInt8(i >> 48),
                UInt8(truncatingIfNeeded: i >> 40),
                UInt8(truncatingIfNeeded: i >> 32),
                UInt8(truncatingIfNeeded: i >> 24),
                UInt8(truncatingIfNeeded: i >> 16),
                UInt8(truncatingIfNeeded: i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        default:
            return Data([
                UInt8(i >> 56),
                UInt8(truncatingIfNeeded: i >> 48),
                UInt8(truncatingIfNeeded: i >> 40),
                UInt8(truncatingIfNeeded: i >> 32),
                UInt8(truncatingIfNeeded: i >> 24),
                UInt8(truncatingIfNeeded: i >> 16),
                UInt8(truncatingIfNeeded: i >> 8),
                UInt8(truncatingIfNeeded: i),
            ])
        }
    }
}
