// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift

class FakeTokensDataStore: TokensDataStore {
    convenience init() {
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealmTest"))
        let account: Wallet = .make()
        let config: Config = .make()
        let web3: Web3Swift = Web3Swift()
        self.init(realm: realm, account: account, config: config, web3: web3)
        self.makeFakeTicker()
    }

    func makeFakeTicker() {
        let price = 947.102
        let eth_contract = "0x0000000000000000000000000000000000000000"
        let rate = Rate(code: "ETH", price: price, contract: eth_contract)
        let currencyRate = CurrencyRate(currency: "USD", rates: [rate])
        let ticker = CoinTicker(id: "ethereum", symbol: "ETH", price: "\(price)", percent_change_24h: "-2.39", contract: eth_contract, image: "https://files.coinmarketcap.com/static/img/coins/128x128/ethereum.png", rate: currencyRate)
        self.tickers = [eth_contract: ticker]
    }
}
