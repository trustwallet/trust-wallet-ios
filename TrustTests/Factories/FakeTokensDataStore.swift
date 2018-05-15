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
