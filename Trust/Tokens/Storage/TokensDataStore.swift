// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt
import Moya
import TrustKeystore

enum TokenAction {
    case updateValue(BigInt)
    case updateBalance
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
        }
    }

    func update(tokens: [TokenObject], action: TokenAction) {
        try! realm.write {
            tokens.forEach { token in
                switch action {
                case .updateValue(let value):
                    token.value = value.description
                case .updateBalance:
                    let currentValue = token.value
                    token.value = currentValue
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
        do {
            config.defaults.set(try PropertyListEncoder().encode(tickers), forKey: "tickers")
        } catch {
            print(error.localizedDescription)
        }
    }

    func tickers() -> [CoinTicker] {

        guard let storedObject: Data = UserDefaults.standard.data(forKey: "tickers") else {
            return [CoinTicker]()
        }

        do {
            return try PropertyListDecoder().decode([CoinTicker].self, from: storedObject)
        } catch {
           return [CoinTicker]()
        }
    }

    func deleteTickers() {
        config.defaults.removeObject(forKey: "tickers")
    }

    static func etherToken(for config: Config) -> TokenObject {
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
