// Copyright DApps Platform Inc. All rights reserved.

import Foundation

final class ShapeShiftBuyWidget {

    private let amount: Int
    private let address: String
    private let publicKey: String
    private let cryptoCurrency: String

    var url: URL {
        return URL(string: "https://shapeshift.io/shifty.html?destination=\(address)&output=\(cryptoCurrency)&amount=\(amount)&apiKey=\(publicKey)")!
    }

    init(
        amount: Int = 0,
        address: String,
        publicKey: String = Constants.shapeShiftPublicKey,
        cryptoCurrency: String = "ETH"
    ) {
        self.amount = amount
        self.address = address
        self.publicKey = publicKey
        self.cryptoCurrency = cryptoCurrency
    }
}
