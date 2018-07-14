// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import TrustCore

struct MonetaryAmountViewModel {
    let amount: String
    let address: EthereumAddress?
    let currencyRate: CurrencyRate?
    let formatter: EtherNumberFormatter

    init(
        amount: String,
        address: EthereumAddress,
        currencyRate: CurrencyRate? = nil,
        formatter: EtherNumberFormatter = .full
    ) {
        self.amount = amount
        self.address = address
        self.currencyRate = currencyRate
        self.formatter = formatter
    }

    var amountCurrency: Double? {
        guard let address = address else {
            return .none
        }
        return currencyRate?.estimate(fee: amount, with: address)
    }

    var amountText: String? {
        guard let amountCurrency = amountCurrency,
            let result = currencyRate?.format(fee: amountCurrency) else {
            return .none
        }
        return "(\(result))"
    }
}
