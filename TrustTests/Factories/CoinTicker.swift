// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension CoinTicker {
    static func make(
            price: String = "0",
            percent_change_24h: String = "0",
            contract: EthereumAddress = .zero,
            currencyKey: String = "currencyKey",
            key: String? = nil
        ) -> CoinTicker {
        let coinTicker = CoinTicker(
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
