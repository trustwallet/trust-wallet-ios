// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Realm
import RealmSwift

class CoinTicker: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var percent_change_24h: String = ""
    @objc dynamic var contract: String = ""
    @objc dynamic var tickersKey: String = ""
    @objc dynamic var key: String = ""

    convenience init(
        id: String = "",
        symbol: String = "",
        price: String = "",
        percent_change_24h: String = "",
        contract: String = "",
        tickersKey: String = ""
    ) {
        self.init()
        self.id = id
        self.symbol = symbol
        self.price = price
        self.percent_change_24h = percent_change_24h
        self.contract = contract
        self.tickersKey = tickersKey
        self.key = "\(self.id)_\(symbol)_\(contract)_\(tickersKey)"
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
        case id
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
