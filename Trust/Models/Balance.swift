// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation

struct Balance: BalanceProtocol {

    let value: BigInt

    init(value: BigInt) {
        self.value = value
    }

    var isZero: Bool {
        return value.isZero
    }

    var amount: String {
        let formatter = EtherNumberFormatter.full
        return formatter.string(from: value)
    }

    var amountFull: String {
        return amount
    }
}
