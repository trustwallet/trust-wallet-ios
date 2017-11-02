// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class CoinbaseBuyWidget {

    private let amount: Int
    private let address: String
    private let widgetCode: String
    private let cryptoCurrency: String

    var url: URL {
        return URL(string: "https://buy.coinbase.com/widget?code=88d6141a-ff60-536c-841c-8f830adaacfd&amount=\(amount)&address=\(address)&crypto_currency=\(cryptoCurrency)")!
    }

    init(
        amount: Int = 0,
        address: String,
        widgetCode: String = Constants.coinbaseWidgetCode,
        cryptoCurrency: String = "ETH"
    ) {
        self.amount = amount
        self.address = address
        self.widgetCode = widgetCode
        self.cryptoCurrency = cryptoCurrency
    }
}
