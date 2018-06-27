// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension CoinTicker {
    static func make(
            symbol: String = "symbol",
            price: String = "0",
            percent_change_24h: String = "0",
            contract: Address = .zero,
            currencyKey: String = "currencyKey",
            key: String? = nil
        ) -> CoinTicker {
        let coinTicker = CoinTicker(
            symbol: symbol,
            price: price,
            percent_change_24h: percent_change_24h,
            contract: contract,
            tickersKey: currencyKey
        )
        if let keyValue = key {
            coinTicker.key = keyValue
        }
        return coinTicker
    }
}
