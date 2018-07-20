// Copyright DApps Platform Inc. All rights reserved.

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
            .sorted(byKeyPath: "createdAt", ascending: true)
    }
    var nonFungibleTokens: Results<NonFungibleTokenCategory> {
        return realm.objects(NonFungibleTokenCategory.self).sorted(byKeyPath: "name", ascending: true)
    }
    let realm: Realm
    let account: WalletInfo
    var objects: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "createdAt", ascending: true)
            .filter { !$0.contract.isEmpty }
    }
    var enabledObject: [TokenObject] {
        return realm.objects(TokenObject.self)
            .sorted(byKeyPath: "createdAt", ascending: true)
            .filter { !$0.isDisabled }
    }
    var nonFungibleObjects: [NonFungibleTokenObject] {
        return realm.objects(NonFungibleTokenObject.self).map { $0 }
    }

    init(
        realm: Realm,
        account: WalletInfo
    ) {
        self.realm = realm
        self.account = account
        self.addEthToken()
    }

    private func addEthToken() {
        if let token = realm.object(ofType: TokenObject.self, forPrimaryKey: EthereumAddress.zero.description) {
            try? realm.write {
                realm.delete(token)
            }
        }

        try? realm.write {
            realm.deleteAll()
        }
        
        let initialCoins = nativeCoin()
        add(tokens: initialCoins)
    }

    private func nativeCoin() -> [TokenObject] {
        return account.accounts.compactMap { ac in
            guard let coin = ac.coin, let server = getServer(for: coin) else {
                return .none
            }
            let viewModel = CoinViewModel(coin: coin)

            return TokenObject(
                contract: server.contract,
                name: viewModel.name,
                coin: coin.rawValue,
                chainID: server.chainID,
                type: .coin,
                symbol: viewModel.symbol,
                decimals: server.decimals,
                value: "0",
                isCustom: false
            )
        }
    }

    private func getServer(for coin: Coin) -> RPCServer? {
        switch coin {
        case .ethereum: return RPCServer.main
        case .ethereumClassic: return RPCServer.classic
        case .poa: return RPCServer.poa
        case .callisto: return RPCServer.callisto
        case .gochain: return RPCServer.gochain
        case .bitcoin: return .none
        }
    }

    static func getServer(for token: TokenObject) -> RPCServer? {
        guard token.chainID > 0 else {
            return .none
        }
        return RPCServer(chainID: token.chainID)
    }

    func coinTicker(for token: TokenObject) -> CoinTicker? {
        guard let contract = EthereumAddress(string: token.contract) else { return .none }
        return tickers().first(where: {
            return $0.key == CoinTickerKeyMaker.makePrimaryKey(symbol: $0.symbol, contract: contract, currencyKey: $0.tickersKey)
        })
    }

    func addCustom(token: ERC20Token) {
        let newToken = TokenObject(
            contract: token.contract.description,
            name: token.name,
            type: .erc20,
            symbol: token.symbol,
            decimals: token.decimals,
            value: "0",
            isCustom: true
        )
        add(tokens: [newToken])
    }

    func add(tokens: [Object]) {
        try? realm.write {
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
        try? realm.write {
            realm.delete(tokens)
        }
    }

    func deleteAll() {
        deleteAllExistingTickers()

        try? realm.write {
            realm.delete(realm.objects(TokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenObject.self))
            realm.delete(realm.objects(NonFungibleTokenCategory.self))
        }
    }

    //Background update of the Realm model.
    func update(balance: BigInt, for address: EthereumAddress) {
        if let tokenToUpdate = enabledObject.first(where: { $0.contract == address.description }) {
            let tokenBalance = self.getBalance(for: tokenToUpdate)

            self.realm.writeAsync(obj: tokenToUpdate) { (realm, _ ) in
                let update = self.objectToUpdate(for: (address, balance), tokenBalance: tokenBalance)
                realm.create(TokenObject.self, value: update, update: true)
            }
        }
    }

    func update(balances: [EthereumAddress: BigInt]) {
        for balance in balances {
            let token = realm.object(ofType: TokenObject.self, forPrimaryKey: balance.key.description)
            let tokenBalance = self.getBalance(for: token)

            try? realm.write {
                let update = objectToUpdate(for: balance, tokenBalance: tokenBalance)
                realm.create(TokenObject.self, value: update, update: true)
            }
        }
    }

    private func objectToUpdate(for balance: (key: EthereumAddress, value: BigInt), tokenBalance: Double) -> [String: Any] {
        return [
            "contract": balance.key.description,
            "value": balance.value.description,
            "balance": tokenBalance,
        ]
    }

    func update(tokens: [TokenObject], action: TokenAction) {
        try? realm.write {
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
        try? realm.write {
            realm.add(tickers, update: true)
        }
    }

    func tickers() -> [CoinTicker] {
        let coinTickers: [CoinTicker] = tickerResultsByTickersKey.map { $0 }

        guard !coinTickers.isEmpty else {
            return [CoinTicker]()
        }

        return coinTickers
    }

    private var tickerResultsByTickersKey: Results<CoinTicker> {
        return realm.objects(CoinTicker.self).filter("tickersKey == %@", CoinTickerKeyMaker.makeCurrencyKey())
    }

    func deleteAllExistingTickers() {
        try? realm.write {
            realm.delete(tickerResultsByTickersKey)
        }
    }

    func getBalance(for token: TokenObject?) -> Double {
        return getBalance(for: token, with: self.tickers())
    }

    func getBalance(for token: TokenObject?, with tickers: [CoinTicker]) -> Double {
        guard let token = token else {
            return TokenObject.DEFAULT_BALANCE
        }

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
