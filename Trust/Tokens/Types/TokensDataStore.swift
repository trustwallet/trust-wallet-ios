// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import APIKit

enum TokenError: Error {
    case failedToFetch
}

protocol TokensDataStoreDelegate: class {
    func didUpdate(result: Result<TokensViewModel, TokenError>)
}

class TokensDataStore {

    let account: Account
    weak var delegate: TokensDataStoreDelegate?
    var tokens: [Token] = []

    init(account: Account) {
        self.account = account
    }

    func update(tokens: [Token]) {
        self.tokens = tokens
        delegate?.didUpdate(result: .success(TokensViewModel(tokens: tokens)))
    }

    func fetch() {
        let request = GetTokensRequest(address: account.address.address)
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.update(tokens: response)
            case .failure:
                self.delegate?.didUpdate(result: .failure(TokenError.failedToFetch))
            }
        }
    }
}
