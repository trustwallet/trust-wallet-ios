// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class CoinbaseBuyWidget {

    private let amount: Int
    private let address: String
    private let widgetCode: String
    private let cryptoCurrency: String

    var url: URL {
        return URL(string: "https://buy.coinbase.com/widget?code=\(widgetCode)&amount=\(amount)&address=\(address)&crypto_currency=\(cryptoCurrency)")!
    }

    init(
        amount: Int = 0,
        address: String,
        code: String = Constants.coinbaseWidgetCode,
        cryptoCurrency: String = "ETH"
    ) {
        self.amount = amount
        self.address = address
        self.widgetCode = code
        self.cryptoCurrency = cryptoCurrency
    }
}
