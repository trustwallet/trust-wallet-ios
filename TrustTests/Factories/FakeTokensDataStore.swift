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
        let eth_contract = "0x0000000000000000000000000000000000000000"
        let coinTiekcer = CoinTicker(id: "ethereum", symbol: "ETH", price: "\(price)", percent_change_24h: "-2.39", contract: eth_contract, image: "https://files.coinmarketcap.com/static/img/coins/128x128/ethereum.png")
        return [coinTiekcer]
    }

    override func tickers() -> [CoinTicker] {
        return makeFakeTicker()
    }
}
