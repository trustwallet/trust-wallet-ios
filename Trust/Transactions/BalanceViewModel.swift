// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation

struct BalanceViewModel {

    let balance: Balance

    init(balance: Balance) {
        self.balance = balance
    }

    var title: String {
        if balance.isZero { return "0.00 ETH" }
        return "\(balance.amount) ETH"
    }
}
