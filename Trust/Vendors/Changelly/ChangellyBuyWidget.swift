// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class ChangellyBuyWidget {

    private let amount: Int
    private let address: String
    private let refferalID: String
    private let cryptoCurrency: String

    var url: URL {
        return URL(string: "https://changelly.com/widget/v1?auth=email&from=BTC&to=\(cryptoCurrency)&merchant_id=\(refferalID)&address=\(address)&amount=\(amount)&ref_id=\(refferalID)&color=00cf70")!
    }

    init(
        amount: Int = 1,
        address: String,
        refferalID: String = Constants.changellyRefferalID,
        cryptoCurrency: String = "ETH"
    ) {
        self.amount = amount
        self.address = address
        self.refferalID = refferalID
        self.cryptoCurrency = cryptoCurrency
    }
}
