// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct CoinTicker: Codable {
    let name: String
    let symbol: String
    let price: String
    let percent_change_24h: String

    static let tokenLogoPath = "https://files.coinmarketcap.com/static/img/coins/128x128/"
}

extension CoinTicker {
    var imageURL: URL? {
        return URL(string: CoinTicker.tokenLogoPath + name.lowercased() + ".png")
    }
}
