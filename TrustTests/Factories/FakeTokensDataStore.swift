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
            CoinTicker.make(symbol: "symbol1", price: "10", contract: .make(address: "0x0000000000000000000000000000000000000001"), currencyKey: currencyKey),
            CoinTicker.make(symbol: "symbol2", price: "20", contract: .make(address: "0x0000000000000000000000000000000000000002"), currencyKey: currencyKey),
            CoinTicker.make(symbol: "symbol3", price: "30", contract: .make(address: "0x0000000000000000000000000000000000000003"), currencyKey: currencyKey),
        ]
    }

    class func make2DuplicateCionTickersWithDifferentKey() -> [CoinTicker] {
        return [
            CoinTicker.make(symbol: "symbol1", contract: .make(), currencyKey: currencyKey, key: "old-key"),
            CoinTicker.make(symbol: "symbol1", contract: .make(), currencyKey: currencyKey),
        ]
    }
}
