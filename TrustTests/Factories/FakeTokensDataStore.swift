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
        let coinTiekcer = CoinTicker.make(symbol: "ETH", price: "\(price)", percent_change_24h: "-2.39", contract: config.server.address)
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
            CoinTicker.make(symbol: "symbol1", price: "10", contract: "contract1", currencyKey: currencyKey),
            CoinTicker.make(symbol: "symbol2", price: "20", contract: "contract2", currencyKey: currencyKey),
            CoinTicker.make(symbol: "symbol3", price: "30", contract: "contract3", currencyKey: currencyKey),
        ]
    }

    class func make2DuplicateCionTickersWithDifferentKey() -> [CoinTicker] {
        return [
            CoinTicker.make(symbol: "same-symbol", contract: "same-contract-address", currencyKey: currencyKey, key: "old-key"),
            CoinTicker.make(symbol: "same-symbol", contract: "same-contract-address", currencyKey: currencyKey),
        ]
    }
}
