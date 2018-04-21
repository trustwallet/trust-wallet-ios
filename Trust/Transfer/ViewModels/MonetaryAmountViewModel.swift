// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct MonetaryAmountViewModel {
    let amount: String
    let symbol: String
    let currencyRate: CurrencyRate?
    let formatter: EtherNumberFormatter

    init(
        amount: String,
        symbol: String,
        currencyRate: CurrencyRate? = nil,
        formatter: EtherNumberFormatter = .full
    ) {
        self.amount = amount
        self.symbol = symbol
        self.currencyRate = currencyRate
        self.formatter = formatter
    }

    var amountText: String? {
        if let amountCurrency = currencyRate?.estimate(fee: amount, with: symbol),
            let result = currencyRate?.format(fee: amountCurrency) {
            return "(\(result))"
        }
        return .none
    }
}
