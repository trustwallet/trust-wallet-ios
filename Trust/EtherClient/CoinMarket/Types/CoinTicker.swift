// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct CoinTicker: Decodable {
    let symbol: String
    let price_usd: String

    var priceUSD: Double {
        return Double(price_usd) ?? 0
    }
}
