// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct CoinTicker: Codable {
    let id: String
    let symbol: String
    let price: String
    let percent_change_24h: String
    let contract: String
    let image: String

    lazy var rate: CurrencyRate = {
        CurrencyRate(
            currency: symbol,
            rates: [
                Rate(
                    code: symbol,
                    price: Double(price) ?? 0,
                    contract: contract
                ),
            ]
        )
    }()
}

extension CoinTicker {
    var imageURL: URL? {
        return URL(string: image)
    }
}
