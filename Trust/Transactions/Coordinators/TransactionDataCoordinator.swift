// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import JSONRPCKit
import APIKit
import RealmSwift
import Result
import Moya

enum TransactionError: Error {
    case failedToFetch
}

protocol TransactionDataCoordinatorDelegate: class {
    func didUpdate(result: Result<[Transaction], TransactionError>)
}

class TransactionDataCoordinator {

    let storage: TransactionsStorage
    let account: Account
    let config = Config()
    var viewModel: TransactionsViewModel {
        return .init(transactions: self.storage.objects)
    }
    var timer: Timer?
    var updateTransactionsTimer: Timer?

    weak var delegate: TransactionDataCoordinatorDelegate?

    private let provider = MoyaProvider<TrustService>()

    init(
        account: Account,
        storage: TransactionsStorage
    ) {
        self.account = account
        self.storage = storage
    }

    func start() {
        fetchTransactions()
        fetchPendingTransactions()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchPending), userInfo: nil, repeats: true)
        updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(fetchTransactions), userInfo: nil, repeats: true)
    }

    func fetch() {
        fetchTransactions()
    }

    @objc func fetchTransactions() {
        let startBlock: Int = {
            guard let transction = storage.objects.first else { return 0 }
            return Int(transction.blockNumber) ?? 0 - 2000
        }()

        provider.request(.transactions(address: account.address.address, startBlock: startBlock)) { result in
            guard  case .success(let response) = result else { return }
            do {
                let transactions = try response.map(RawTransactionResponse.self).docs
                let chainID = self.config.chainID
                let transactions2: [Transaction] = transactions.map { .from(
                        chainID: chainID,
                        owner: self.account.address,
                        transaction: $0
                    )
                }
                self.update(items: transactions2)
            } catch {
                NSLog("error \(error)")
            }
        }
    }

    func fetchPendingTransactions() {
        //Implement fetching pending transactions
    }

    func fetchTransaction(hash: String) {

    }

    @objc func fetchPending() {
        fetchPendingTransactions()
    }

    @objc func fetchLatest() {
        fetchTransactions()
    }

    func update(items: [Transaction]) {
        storage.add(items)
        handleUpdateItems()
    }

    func handleError(error: Error) {
        delegate?.didUpdate(result: .failure(TransactionError.failedToFetch))
    }

    func handleUpdateItems() {
        delegate?.didUpdate(result: .success(self.storage.objects))
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
    }
}
