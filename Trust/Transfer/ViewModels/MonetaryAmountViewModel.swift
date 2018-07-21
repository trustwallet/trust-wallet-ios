// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import TrustCore

struct MonetaryAmountViewModel {
    let amount: String
    let priceID: String
    let currencyRate: CurrencyRate?
    let formatter: EtherNumberFormatter

    init(
        amount: String,
        priceID: String,
        currencyRate: CurrencyRate? = nil,
        formatter: EtherNumberFormatter = .full
    ) {
        self.amount = amount
        self.priceID = priceID
        self.currencyRate = currencyRate
        self.formatter = formatter
    }

    var amountCurrency: Double? {
        return currencyRate?.estimate(fee: amount, with: priceID)
    }

    var amountText: String? {
        guard let amountCurrency = amountCurrency,
            let result = currencyRate?.format(fee: amountCurrency) else {
            return .none
        }
        return "(\(result))"
    }
}
