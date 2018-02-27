// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt
import Moya
import TrustKeystore

/// Enum of the token actions.
///
/// - Cases:
///   - updateValue: of the token.
///   - disable: token.
enum TokenAction {
    case updateValue(BigInt)
    case disable(Bool)
}

class TokensDataStore {
    /// tokens of a `TokensDataStore` to represent curent enabled tokens.
    var tokens: Results<TokenObject> {
        return realm.objects(TokenObject.self).filter(NSPredicate(format: "isDisabled == NO"))
            .sorted(byKeyPath: "contract", ascending: true)
    }
    /// config of a `TokensDataStore` current configuration of the app.
    let config: Config
    /// realm of a `TokensDataStore` instance of the Realm database.
    let realm: Realm
    /// tickers of a `TokensDataStore` ticker for each token price in current fiat currency.
    private var tickers: [CoinTicker] = []
    /// objects of a `TokensDataStore` all tokens that are in Realm database.
    var objects: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "contract", ascending: true)
            .filter { !$0.contract.isEmpty }
    }
    /// enabledObject of a `TokensDataStore` all enabled tokens that are in Realm database.
    var enabledObject: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "contract", ascending: true)
            .filter { !$0.isDisabled }
    }
    /// Construtor.
    ///
    /// - Parameters:
    ///   - realm: instance of the Realm database.
    ///   - config: configuration of the app.
    init(
        realm: Realm,
        config: Config
    ) {
        self.config = config
        self.realm = realm
        self.addEthToken()
    }
    /// Add eth as first token.
    private func addEthToken() {
        //Check if we have previos values.
        let etherToken = TokensDataStore.etherToken(for: config)
        if objects.first(where: { $0 == etherToken }) == nil {
            add(tokens: [etherToken])
        }
    }
    /// Ticker for requested token.
    ///
    /// - Parameters:
    ///   - token: to fetch ticker.
    /// - Returns: `CoinTicker` ticker for token.
    func coinTicker(for token: TokenObject) -> CoinTicker? {
        return tickers.first(where: { $0.contract == token.contract })
    }
    /// Add custom ERC-20 token.
    ///
    /// - Parameters:
    ///   - token: ERC-20 to add.
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
    /// Add tokens to database.
    ///
    /// - Parameters:
    ///   - tokens: array to add.
    func add(tokens: [TokenObject]) {
        realm.beginWrite()
        realm.add(tokens, update: true)
        try! realm.commitWrite()
    }
    /// Delete token from database.
    ///
    /// - Parameters:
    ///   - tokens: array to delete.
    func delete(tokens: [TokenObject]) {
        realm.beginWrite()
        realm.delete(tokens)
        try! realm.commitWrite()
    }
    /// Delete all token from database.
    func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(TokenObject.self))
        }
    }
    /// Update token with action.
    ///
    /// - Parameters:
    ///   - token: to update.
    ///   - action: to perform.
    func update(token: TokenObject, action: TokenAction) {
        try! realm.write {
            switch action {
            case .updateValue(let value):
                if token.value != value.description {
                    token.value = value.description
                }
            case .disable(let value):
                token.isDisabled = value
            }
        }
    }
    /// Update or add new tokens to database from transactions.
    ///
    /// - Parameters:
    ///   - realm: instance of the Realm database.
    ///   - tokens: to add or update.
    static func update(in realm: Realm, tokens: [Token]) {
        realm.beginWrite()
        for token in tokens {
            let update: [String: Any] = [
                "contract": token.address.description,
                "name": token.name,
                "symbol": token.symbol,
                "decimals": token.decimals,
                ]
            realm.create(TokenObject.self, value: update, update: true)
        }
        try! realm.commitWrite()
    }
    /// ETH token constrcutor.
    ///
    /// - Parameters:
    ///   - config: parameters of the token.
    /// - Returns: `TokenObject` ETH token.
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
