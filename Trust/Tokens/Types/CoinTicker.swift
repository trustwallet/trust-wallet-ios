// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Realm
import RealmSwift

class CoinTicker: Object, Decodable {
    @objc dynamic var symbol: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var percent_change_24h: String = ""
    @objc dynamic var contract: String = ""
    @objc dynamic var currencyKey: String = ""
    @objc dynamic var key: String = ""

    convenience init(
        symbol: String = "",
        price: String = "",
        percent_change_24h: String = "",
        contract: String = "",
        currencyKey: String = ""
    ) {
        self.init()
        self.symbol = symbol
        self.price = price
        self.percent_change_24h = percent_change_24h
        self.contract = contract
        self.currencyKey = currencyKey
        self.key = CoinTickerKeyMaker.makePrimaryKey(symbol: symbol, contract: contract, currencyKey: currencyKey)
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
        case symbol
        case price
        case percent_change_24h
        case contract
    }
}

extension CoinTicker {
    func rate() -> CurrencyRate {
        return CurrencyRate(
            rates: [
                Rate(
                    code: symbol,
                    price: Double(price) ?? 0,
                    contract: contract
                ),
            ]
        )
    }
}

struct CoinTickerKeyMaker {
    static func makePrimaryKey(symbol: String, contract: String, currencyKey: String) -> String {
        return "\(symbol)_\(contract)_\(currencyKey)"
    }

    static func makeCurrencyKey(for config: Config) -> String {
        return "currency-" + config.currency.rawValue + "-" + String(config.chainID)
    }
}
