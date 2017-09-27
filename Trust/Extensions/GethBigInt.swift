// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

extension GethBigInt {
    static func from(data: Data?) -> GethBigInt {
        let value = GethNewBigInt(0)!
        value.setBytes(data)
        return value
    }

    static func from(hex: String) -> GethBigInt {
        let value = GethNewBigInt(0)!
        value.setString(hex, base: 16)
        return value
    }

    static func from(decimal: NSDecimalNumber) -> GethBigInt {
        let bignum = Bignum(decimal.description(withLocale: nil))
        return GethBigInt.from(hex: bignum.asString(withBase: 16))
    }
}
