// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import APIKit

protocol TransactionDataStoreDelegate: class {
    func didUpdate(viewModel: TransactionsViewModel)
    func didFail(with error: Error, viewModel: TransactionsViewModel)
}

class TransactionDataStore {

    var viewModel: TransactionsViewModel {
        return .init(transactions: transactions)
    }
    weak var delegate: TransactionDataStoreDelegate?

    let account: Account
    var transactions: [Transaction] = []
    var tokens: [Token] = []
    init(account: Account) {
        self.account = account
    }

    func fetch() {
        fetchTransactions()
        fetchTokens()
    }

    func update(transactions: [Transaction]) {
        self.transactions = transactions
        delegate?.didUpdate(viewModel: viewModel)
    }

    func update(tokens: [Token]) {
        self.tokens = tokens
    }

    func fetchTransactions() {
        let request = FetchTransactionsRequest(address: account.address.address)
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.update(transactions: response)
            case .failure(let error):
                self.delegate?.didFail(with: error, viewModel: self.viewModel)
            }
        }
    }

    func fetchTokens() {
        let request = GetTokensRequest(address: account.address.address)
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.update(tokens: response)
            case .failure(let error):
                self.delegate?.didFail(with: error, viewModel: self.viewModel)
            }
        }
    }
}
