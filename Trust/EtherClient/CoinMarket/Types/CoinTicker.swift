// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct CoinTicker: Codable {
    let id: String
    let name: String
    let symbol: String
    let price: String
    let percent_change_24h: String
    let contract: String

    static let tokenLogoPath = "https://files.coinmarketcap.com/static/img/coins/128x128/"
    
    lazy var rate: CurrencyRate = {
        CurrencyRate(
            currency: self.symbol,
            rates: [
                Rate(
                    code: self.symbol,
                    price: Double(self.price) ?? 0,
                    contract: self.contract
                ),
            ]
        )
    }()
}

extension CoinTicker {
    var imageURL: URL? {
        return URL(string: CoinTicker.tokenLogoPath + id + ".png")
    }
}
