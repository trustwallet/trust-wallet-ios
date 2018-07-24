// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import RealmSwift
import TrustCore

class FakeTokensDataStore: TokensDataStore {
    convenience init() {
        let realm = Realm.make()
        self.init(realm: realm, account: .make())
    }
}

class FakeCoinTickerFactory {
    static let currencyKey = CoinTickerKeyMaker.makeCurrencyKey()

    class func make3UniqueCionTickers() -> [CoinTicker] {
        return [
            CoinTicker.make(price: "10", contract: .make(address: "0x0000000000000000000000000000000000000001"), currencyKey: currencyKey),
            CoinTicker.make(price: "20", contract: .make(address: "0x0000000000000000000000000000000000000002"), currencyKey: currencyKey),
            CoinTicker.make(price: "30", contract: .make(address: "0x0000000000000000000000000000000000000003"), currencyKey: currencyKey),
        ]
    }

    class func make2DuplicateCionTickersWithDifferentKey() -> [CoinTicker] {
        return [
            CoinTicker.make(contract: .make(), currencyKey: currencyKey, key: "old-key"),
            CoinTicker.make(contract: .make(), currencyKey: currencyKey),
        ]
    }
}
