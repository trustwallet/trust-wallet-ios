// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit
import RealmSwift
import BigInt

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

    let session: WalletSession
    weak var delegate: TokensDataStoreDelegate?
    let realm: Realm

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
        switch session.config.server {
        case .main:
            let request = GetTokensRequest(address: session.account.address.address)
            Session.send(request) { result in
                switch result {
                case .success(let response):
                    self.update(tokens: response)
                    self.refreshBalance()
                case .failure:
                    self.delegate?.didUpdate(result: .failure(TokenError.failedToFetch))
                }
            }
        case .kovan, .poa, .poaTest, .ropsten:
            self.refreshBalance()
        }
    }

    func refreshBalance() {
        guard !objects.isEmpty else {
            delegate?.didUpdate(result: .success(TokensViewModel(tokens: [])))
            return
        }
        let updateTokens = objects
        var count = 0
        for tokenObject in objects {
            getBalanceCoordinator.getBalance(for: session.account.address, contract: Address(address: tokenObject.contract)) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    self.update(token: tokenObject, value: balance)
                case .failure(let error):
                    self.handleError(error: error)
                }
                count += 1
                if count == updateTokens.count {
                    self.delegate?.didUpdate(result: .success(TokensViewModel(tokens: self.objects)))
                }
            }
        }
    }

    func handleError(error: Error) {
        delegate?.didUpdate(result: .failure(TokenError.failedToFetch))
    }

    func addCustom(token: ERC20Token) {
        let newToken = TokenObject(
            contract: token.contract.address,
            name: token.name,
            symbol: token.symbol,
            decimals: token.decimals,
            value: "0",
            isCustom: true
        )
        add(tokens: [newToken])
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

    func update(token: TokenObject, value: BigInt) {
        realm.beginWrite()
        token.value = value.description
        try! realm.commitWrite()
    }
}
