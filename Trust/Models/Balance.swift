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
        return EthereumConverter.from(value: value, to: .wei, minimumFractionDigits: 2)
    }

    var amount: String {
        return EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 4)
    }

    var amountFull: String {
        // TODO Implement full amount
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
