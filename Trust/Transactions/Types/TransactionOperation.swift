// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class TransactionOperation: TrustOperation {

    private let network: TrustNetwork

    private let session: WalletSession

    private var page = 0

    var transactionsHistory = [Transaction]()

    private lazy var tracker: TransactionsTracker = {
        return TransactionsTracker(sessionID: self.session.sessionID)
    }()

    init(
        network: TrustNetwork,
        session: WalletSession
        ) {
        self.network = network
        self.session = session
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        executing(true)
        fetchTransactions()
    }

    private func fetchTransactions() {
        transactions(for: page) { [weak self] (result, state) in
            guard let transactions = result, state == .initial else {
                if state == .failed {
                    self?.tracker.fetchingState = .failed
                } else {
                    self?.tracker.fetchingState = .done
                }
                self?.executing(false)
                self?.finish(true)
                return
            }
            self?.transactionsHistory.append(contentsOf: transactions)
            self?.page += 1
            self?.fetchTransactions()
        }
    }

    private func transactions(for page: Int, completion: @escaping (([Transaction]?, TransactionFetchingState) -> Void)) {
        self.network.transactions(for: self.session.account.address, startBlock: 1, page: page, contract: nil) { result in
            guard let transactions = result.0, result.1 else {
                completion(nil, .failed)
                return
            }
            if !transactions.isEmpty && page <= 5 {
                completion(transactions, .initial)
            } else {
                completion(nil, .done)
            }
        }
    }
}
