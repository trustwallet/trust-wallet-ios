// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt
import Moya
import TrustCore

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

    func coinTicker(for token: TokenObject) -> CoinTickerObject? {
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
            if let tokenObjects = tokens as? [TokenObject] {
                let tokenObjectsWithBalance = tokenObjects.map { tokenObject -> TokenObject in
                    tokenObject.balance = self.getBalance(for: tokenObject, with: self.tickers())
                    return tokenObject
                }
                realm.add(tokenObjectsWithBalance, update: true)
            } else {
                realm.add(tokens, update: true)
            }
        }
    }

    func delete(tokens: [Object]) {
        try! realm.write {
            realm.delete(tokens)
        }
    }

    func deleteAll() {
        deleteAllExistingTickers()
        try! realm.write {
            realm.delete(realm.objects(TokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenCategory.self))
        }
    }

    func update(balances: [Address: BigInt]) {
        try! realm.write {
            for balance in balances {
                guard let tokenObject = realm.object(ofType: TokenObject.self, forPrimaryKey: balance.key.description) else {
                    continue
                }

                tokenObject.value = balance.value.description
                tokenObject.balance = self.getBalance(for: tokenObject, with: self.tickers())

                realm.add(tokenObject, update: true)
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

    func saveTickers(tickers: [CoinTickerObject]) {
        guard !tickers.isEmpty else {
            return
        }

        deleteAllExistingTickers()

        let coinTickerObjects = tickers.map { (ticker) -> CoinTickerObject in
            let tickersKey = self.config.tickersKey
            return CoinTickerObject(
                id: ticker.id,
                symbol: ticker.symbol,
                price: ticker.price,
                percent_change_24h: ticker.percent_change_24h,
                contract: ticker.contract,
                image: ticker.image,
                tickersKey: tickersKey
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

    func tickers() -> [CoinTickerObject] {
        let coinTickerObjects: [CoinTickerObject] = tickerResultsByTickersKey.map { $0 }

        guard !coinTickerObjects.isEmpty else {
            return [CoinTickerObject]()
        }

        return coinTickerObjects
    }

    private var tickerResultsByTickersKey: Results<CoinTickerObject> {
        return realm.objects(CoinTickerObject.self).filter("tickersKey == %@", self.config.tickersKey)
    }

    func deleteAllExistingTickers() {
        do {
            try realm.write {
                realm.delete(tickerResultsByTickersKey)
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

    func getBalance(for token: TokenObject, with tickers: [CoinTickerObject]) -> Double {
        guard let ticker = tickers.first(where: { $0.contract == token.contract }) else {
            return TokenObject.DEFAULT_BALANCE
        }

        guard let amountInBigInt = BigInt(token.value), let price = Double(ticker.price) else {
            return TokenObject.DEFAULT_BALANCE
        }

        guard let amountInDecimal = EtherNumberFormatter.full.decimal(from: amountInBigInt, decimals: token.decimals) else {
            return TokenObject.DEFAULT_BALANCE
        }

        return amountInDecimal.doubleValue * price
    }
}
