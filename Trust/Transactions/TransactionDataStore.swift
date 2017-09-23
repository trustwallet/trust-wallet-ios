// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import APIKit
import Result

enum TransactionError: Error {
    case failedToFetch
}

enum TokenError: Error {
    case failedToFetch
}

protocol TransactionDataStoreDelegate: class {
    func didUpdate(result: Result<TransactionsViewModel, TransactionError>)
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
    }

    func update(transactions: [Transaction]) {
        self.transactions = transactions
        delegate?.didUpdate(result: .success(viewModel))
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
            case .failure:
                self.delegate?.didUpdate(result: .failure(TransactionError.failedToFetch))
            }
        }
    }
}
