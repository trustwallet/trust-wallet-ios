// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct BalanceViewModel: BalanceBaseViewModel {

    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        //TODO: use current locale when available this feature
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        return formatter
    }

    let balance: Balance?
    let rate: CurrencyRate?
    let config: Config

    init(
        balance: Balance? = .none,
        rate: CurrencyRate? = .none,
        config: Config = Config()
    ) {
        self.balance = balance
        self.rate = rate
        self.config = config
    }

    var amount: Double {
        guard let balance = balance else { return 0.00 }
        return balance.amountFull.doubleValue
    }

    var amountString: String {
        guard let balance = balance else { return "--" }
        guard !balance.isZero else { return "0.00 \(config.server.symbol)" }
        return "\(balance.amountFull) \(config.server.symbol)"
    }

    var currencyAmount: String? {
        guard let rate = rate else { return nil }
        guard
            let currentRate = (rate.rates.filter { $0.code == config.server.symbol }.first),
            currentRate.price > 0,
            amount > 0
        else { return nil }
        let totalAmount = amount * currentRate.price
        return BalanceViewModel.formatter.string(from: NSNumber(value: totalAmount))
    }

    var amountFull: String {
        return balance?.amountFull ?? "--"
    }

    var amountShort: String {
        return balance?.amountShort ?? "--"
    }

    var symbol: String {
        return config.server.symbol
    }
}
