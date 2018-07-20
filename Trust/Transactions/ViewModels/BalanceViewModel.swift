// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct BalanceViewModel: BalanceBaseViewModel {

    let balance: Balance?
    let rate: CurrencyRate?
    let server: RPCServer

    init(
        server: RPCServer,
        balance: Balance? = .none,
        rate: CurrencyRate? = .none
    ) {
        self.server = server
        self.balance = balance
        self.rate = rate
    }

    var amount: Double {
        guard let balance = balance else { return 0.00 }
        return CurrencyFormatter.plainFormatter.string(from: balance.value).doubleValue
    }

    var amountString: String {
        guard let balance = balance else { return "--" }
        guard !balance.isZero else { return "0.00 \(server.symbol)" }
        return "\(balance.amountFull) \(server.symbol)"
    }

    var currencyAmount: String? {
        guard let rate = rate else { return nil }
        guard
            let currentRate = (rate.rates.filter { $0.contract == server.address.description }.first),
            currentRate.price > 0,
            amount > 0
        else { return nil }
        let totalAmount = amount * currentRate.price
        return CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount))
    }

    var amountFull: String {
        return balance?.amountFull ?? "--"
    }

    var amountShort: String {
        return balance?.amountShort ?? "--"
    }

    var symbol: String {
        return server.symbol
    }
}
