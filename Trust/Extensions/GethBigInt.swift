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

    static func from(double: BDouble) -> GethBigInt {
        let bignum = Bignum(double.description)
        return GethBigInt.from(hex: bignum.asString(withBase: 16))
    }

    static func from(int: Int) -> GethBigInt {
        return GethNewBigInt(Int64(int))
    }
}
