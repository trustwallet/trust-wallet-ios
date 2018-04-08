// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt
import Moya
import TrustKeystore

enum TokenAction {
    case disable(Bool)
    case updateInfo
}

class TokensDataStore {
    var tokens: Results<TokenObject> {
        return realm.objects(TokenObject.self).filter(NSPredicate(format: "isDisabled == NO"))
            .sorted(byKeyPath: "contract", ascending: true)
    }
    var nonFungibleTokens: Results<NonFungibleTokenCategory> {
        return realm.objects(NonFungibleTokenCategory.self).sorted(byKeyPath: "name", ascending: true)
    }
    let config: Config
    let realm: Realm
    var objects: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "contract", ascending: true)
            .filter { !$0.contract.isEmpty }
    }
    var enabledObject: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "contract", ascending: true)
            .filter { !$0.isDisabled }
    }
    var nonFungibleObjects: [NonFungibleTokenObject] {
        return realm.objects(NonFungibleTokenObject.self).map { $0 }
    }

    private lazy var tickersKey: String = {
        return "tickers-" + config.currency.rawValue + "-" + String(config.chainID)
    }()

    init(
        realm: Realm,
        config: Config
    ) {
        self.config = config
        self.realm = realm
        self.addEthToken()
    }

    private func addEthToken() {
        let etherToken = TokensDataStore.etherToken(for: config)
        if objects.first(where: { $0 == etherToken }) == nil {
            add(tokens: [etherToken])
        }
    }

    func coinTicker(for token: TokenObject) -> CoinTicker? {
        return tickers().first(where: { $0.contract == token.contract })
    }

    func addCustom(token: ERC20Token) {
        let newToken = TokenObject(
            contract: token.contract.description,
            name: token.name,
            symbol: token.symbol,
            decimals: token.decimals,
            value: "0",
            isCustom: true
        )
        add(tokens: [newToken])
    }

    func add(tokens: [Object]) {
        try! realm.write {
            realm.add(tokens, update: true)
        }
    }

    func delete(tokens: [Object]) {
        try! realm.write {
            realm.delete(tokens)
        }
    }

    func deleteAll() {
        deleteTickers()
        try! realm.write {
            realm.delete(realm.objects(TokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenCategory.self))
        }
    }

    func update(balances: [Address: BigInt]) {
        try! realm.write {
            for balance in balances {
                let update = [
                    "contract": balance.key.description,
                    "value": balance.value.description,
                ]
                realm.create(TokenObject.self, value: update, update: true)
            }
        }
    }

    func update(tokens: [TokenObject], action: TokenAction) {
        try! realm.write {
            for token in tokens {
                switch action {
                case .disable(let value):
                    token.isDisabled = value
                case .updateInfo:
                    let update: [String: Any] = [
                        "contract": token.address.description,
                        "name": token.name,
                        "symbol": token.symbol,
                        "decimals": token.decimals,
                    ]
                    realm.create(TokenObject.self, value: update, update: true)
                }
            }
        }
    }

    func saveTickers(tickers: [CoinTicker]) {
        guard !tickers.isEmpty else {
            return
        }

        /*
        do {
            config.defaults.set(try PropertyListEncoder().encode(tickers), forKey: tickersKey)
        } catch {
            print(error.localizedDescription)
        }
        */

        deleteTickers()

        let coinTickerObjects = tickers.map { (ticker) -> CoinTickerObject in
            return CoinTickerObject(
                id: ticker.id,
                symbol: ticker.symbol,
                price: ticker.price,
                percent_change_24h: ticker.percent_change_24h,
                contract: ticker.contract,
                image: ticker.image,
                tickersKey: self.tickersKey
            )
        }

        do {
            try realm.write {
                realm.add(coinTickerObjects, update: true)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func tickers() -> [CoinTicker] {
        /*
        guard let storedObject: Data = config.defaults.data(forKey: tickersKey) else {
            return [CoinTicker]()
        }

        do {
            return try PropertyListDecoder().decode([CoinTicker].self, from: storedObject)
        } catch {
           return [CoinTicker]()
        }
        */

        let coinTickerObjects: [CoinTickerObject] = getTickerResultsByTickersKey().map { $0 }

        let tickers = coinTickerObjects.map { (coinTickerObject) -> CoinTicker in
            return CoinTicker(
                id: coinTickerObject.id,
                symbol: coinTickerObject.symbol,
                price: coinTickerObject.price,
                percent_change_24h: coinTickerObject.percent_change_24h,
                contract: coinTickerObject.contract,
                image: coinTickerObject.image
            )
        }

        guard !tickers.isEmpty else {
            return [CoinTicker]()
        }

        return tickers
    }

    func getTickerResultsByTickersKey() -> Results<CoinTickerObject> {
        return realm.objects(CoinTickerObject.self).filter("tickersKey == %@", self.tickersKey)
    }

    func deleteTickers() {
        /*
        config.defaults.removeObject(forKey: tickersKey)
        */

        let results = getTickerResultsByTickersKey()

        do {
            try realm.write {
                realm.delete(results)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    static func etherToken(for config: Config = .current) -> TokenObject {
        return TokenObject(
            contract: "0x0000000000000000000000000000000000000000",
            name: config.server.name,
            symbol: config.server.symbol,
            decimals: config.server.decimals,
            value: "0",
            isCustom: false
        )
    }
}
