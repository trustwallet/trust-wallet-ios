// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTokensDataStore: TokensDataStore {
    convenience init() {
        let realm = Realm.make()
        let config: Config = .make()
        self.init(realm: realm, config: config)
    }

    func makeFakeTicker() -> [CoinTicker]  {
        let price = 947.102
        let coinTiekcer = CoinTicker(symbol: "ETH", price: "\(price)", percent_change_24h: "-2.39", contract: config.server.address, tickersKey: "tickersKey")
        return [coinTiekcer]
    }

    override func tickers() -> [CoinTicker] {
        return makeFakeTicker()
    }
}

class FakeCoinTickerFactory {
    static let currencyKey = CoinTickerKeyMaker.makeCurrencyKey(for: Config.make())

    class func make3UniqueCionTickers() -> [CoinTicker] {
        return [
            CoinTicker(symbol: "symbol1", price: "10", percent_change_24h: "percent_change_24h_1", contract: "contract1", tickersKey: currencyKey),
            CoinTicker(symbol: "symbol2", price: "20", percent_change_24h: "percent_change_24h_2", contract: "contract2", tickersKey: currencyKey),
            CoinTicker(symbol: "symbol3", price: "30", percent_change_24h: "percent_change_24h_3", contract: "contract3", tickersKey: currencyKey),
        ]
    }

    class func make2DuplicateCionTickersWithDifferentKey() -> [CoinTicker] {
        return [
            {
                let coinTicker = CoinTicker(symbol: "same-symbol", price: "", percent_change_24h: "", contract: "same-contract-address", tickersKey: currencyKey)
                coinTicker.key = "old-key"
                return coinTicker
            }(),
            {
                let coinTicker = CoinTicker(symbol: "same-symbol", price: "", percent_change_24h: "", contract: "same-contract-address", tickersKey: currencyKey)
                return coinTicker
            }()
        ]
    }
}
