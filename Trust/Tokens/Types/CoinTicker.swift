// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Realm
import RealmSwift
import TrustCore

final class CoinTicker: Object, Decodable {
    @objc dynamic var price: String = ""
    @objc dynamic var percent_change_24h: String = ""
    @objc dynamic var contract: String = ""
    @objc dynamic var tickersKey: String = ""
    @objc dynamic var key: String = ""

    convenience init(
        price: String = "",
        percent_change_24h: String = "",
        contract: EthereumAddress,
        tickersKey: String = ""
    ) {
        self.init()
        self.price = price
        self.percent_change_24h = percent_change_24h
        self.contract = contract.description
        self.tickersKey = tickersKey

        self.key = CoinTickerKeyMaker.makePrimaryKey(contract: contract, currencyKey: tickersKey)
    }

    required init() {
        super.init()
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    override static func primaryKey() -> String? {
        return "key"
    }

    enum CodingKeys: String, CodingKey {
        case price
        case percent_change_24h
        case contract
    }
}

struct CoinTickerKeyMaker {
    static func makePrimaryKey(contract: Address, currencyKey: String) -> String {
        return "\(contract)_\(currencyKey)"
    }

    static func makeCurrencyKey() -> String {
        return "tickers-" + Config.current.currency.rawValue
    }
}
