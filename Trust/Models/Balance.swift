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

    var wei: String {
        let formatter = EtherNumberFormatter.short
        return formatter.string(from: value, units: .wei)
    }

    var amount: String {
        let formatter = EtherNumberFormatter.full
        return formatter.string(from: value)
    }

    var amountFull: String {
        return amount
    }
}

extension String {
    var drop0x: String {
        if self.count > 2 && self.substring(with: 0..<2) == "0x" {
            return String(self.dropFirst(2))
        }
        return self
    }

    var add0x: String {
        return "0x" + self
    }
}
