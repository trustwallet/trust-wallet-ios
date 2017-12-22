// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt
import Moya

enum TokenError: Error {
    case failedToFetch
}

protocol TokensDataStoreDelegate: class {
    func didUpdate(result: Result<TokensViewModel, TokenError>)
}

class TokensDataStore {

    private lazy var getBalanceCoordinator: GetBalanceCoordinator = {
        return GetBalanceCoordinator(session: self.session)
    }()
    private let provider = MoyaProvider<CoinMarketService>()

    let session: WalletSession
    weak var delegate: TokensDataStoreDelegate?
    let realm: Realm
    var tickers: [String: CoinTicker]? = .none

    init(
        session: WalletSession,
        configuration: Realm.Configuration
    ) {
        self.session = session
        self.realm = try! Realm(configuration: configuration)
    }

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

    func update(tokens: [Token]) {
        realm.beginWrite()
        for token in tokens {
            let update: [String: Any] = [
                "owner": session.account.address.address,
                "chainID": session.config.chainID,
                "contract": token.address.address,
                "name": token.name,
                "symbol": token.symbol,
                "decimals": token.decimals,
            ]
            realm.create(
                TokenObject.self,
                value: update,
                update: true
            )
        }
        try! realm.commitWrite()
    }

    func fetch() {
        let contracts = uniqueContracts()
        update(tokens: contracts)

        switch session.config.server {
        case .main:
            let request = GetTokensRequest(address: session.account.address.address)
            Session.send(request) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let response):
                    self.update(tokens: response)
                    self.refreshBalance()
                case .failure(let error):
                    self.handleError(error: error)
                }
            }
            updatePrices()
        case .kovan, .poa, .ropsten:
            self.refreshBalance()
        }
    }

    func refreshBalance() {
        guard !objects.isEmpty else {
            updateDelegate()
            return
        }
        let updateTokens = objects
        var count = 0
        for tokenObject in objects {
            getBalanceCoordinator.getBalance(for: session.account.address, contract: Address(address: tokenObject.contract)) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    self.update(token: tokenObject, action: .value(balance))
                case .failure(let error):
                    self.handleError(error: error)
                }
                count += 1
                if count == updateTokens.count {
                   self.updateDelegate()
                }
            }
        }
    }

    func updateDelegate() {
        let balance = TokenObject(
            contract: "0x",
            name: session.config.server.name,
            symbol: session.config.server.symbol,
            decimals: session.config.server.decimals,
            value: session.balance?.value.description ?? "0",
            isCustom: false,
            type: .ether
        )

        var results = enabledObject
        results.insert(balance, at: 0)

        delegate?.didUpdate(result: .success(
            TokensViewModel(
                tokens: results,
                tickers: tickers
            ))
        )
    }

    func handleError(error: Error) {
        delegate?.didUpdate(result: .failure(TokenError.failedToFetch))
    }

    func addCustom(token: ERC20Token) {
        let newToken = TokenObject(
            contract: token.contract.address,
            symbol: token.symbol,
            decimals: token.decimals,
            value: "0",
            isCustom: true
        )
        add(tokens: [newToken])
    }

    func updatePrices() {
        provider.request(.prices(limit: 0)) { result in
            guard  case .success(let response) = result else { return }
            do {
                let tickers = try response.map([CoinTicker].self)
                self.tickers = tickers.reduce([String: CoinTicker]()) { (dict, ticker) -> [String: CoinTicker] in
                    var dict = dict
                    dict[ticker.symbol] = ticker
                    return dict
                }
                self.updateDelegate()
            } catch { }
        }
    }

    @discardableResult
    func add(tokens: [TokenObject]) -> [TokenObject] {
        realm.beginWrite()
        realm.add(tokens, update: true)
        try! realm.commitWrite()
        return tokens
    }

    func delete(tokens: [TokenObject]) {
        realm.beginWrite()
        realm.delete(tokens)
        try! realm.commitWrite()
    }

    enum TokenUpdate {
        case value(BigInt)
        case isDisabled(Bool)
    }

    func update(token: TokenObject, action: TokenUpdate) {
        realm.beginWrite()
        switch action {
        case .value(let value):
            token.value = value.description
        case .isDisabled(let value):
            token.isDisabled = value
        }
        try! realm.commitWrite()
    }

    func uniqueContracts() -> [Token] {
        let transactions = realm.objects(Transaction.self)
            .sorted(byKeyPath: "date", ascending: true)
            .filter { !$0.localizedOperations.isEmpty }

        let tokens: [Token] = transactions.flatMap { transaction in
            guard
                let operation = transaction.localizedOperations.first,
                let contract = operation.contract,
                let name = operation.name,
                let symbol = operation.symbol else { return nil }
            return Token(
                address: Address(address: contract),
                name: name,
                symbol: symbol,
                decimals: operation.decimals
            )
        }
        return tokens
    }
}
