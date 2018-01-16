// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import JSONRPCKit
import APIKit
import RealmSwift
import Result
import Moya
import TrustKeystore

enum TransactionError: Error {
    case failedToFetch
}

protocol TransactionDataCoordinatorDelegate: class {
    func didUpdate(result: Result<[Transaction], TransactionError>)
}

class TransactionDataCoordinator {

    let storage: TransactionsStorage
    let session: WalletSession
    let config = Config()
    var viewModel: TransactionsViewModel {
        return .init(transactions: self.storage.objects)
    }
    var timer: Timer?
    var updateTransactionsTimer: Timer?

    weak var delegate: TransactionDataCoordinatorDelegate?

    private let trustProvider = TrustProviderFactory.makeProvider()

    init(
        session: WalletSession,
        storage: TransactionsStorage
    ) {
        self.session = session
        self.storage = storage
    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchPending), userInfo: nil, repeats: true)
        updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(fetchTransactions), userInfo: nil, repeats: true)
    }

    func fetch() {
        session.refresh(.balance)
        fetchTransactions()
        fetchPendingTransactions()
    }

    @objc func fetchTransactions() {
        let startBlock: Int = {
            guard let transaction = storage.objects.first, storage.objects.count >= 30 else {
                return 1
            }
            return transaction.blockNumber - 2000
        }()
        trustProvider.request(.getTransactions(address: session.account.address.address, startBlock: startBlock)) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                do {
                    let transactions = try response.map(ArrayResponse<RawTransaction>.self).docs
                    let chainID = self.config.chainID
                    let transactions2: [Transaction] = transactions.flatMap { .from(
                        chainID: chainID,
                        owner: self.session.account.address,
                        transaction: $0
                        )
                    }
                    self.update(items: transactions2)
                } catch {
                    self.handleError(error: error)
                }
            case .failure(let error):
                self.handleError(error: error)
            }
        }
    }

    func fetchPendingTransactions() {
        // TODO: Handle pending transactions


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

    func update(chainID: Int, owner: Address, items: [ParsedTransaction]) {
        let transactionItems: [Transaction] = items.map { .from(chainID: chainID, owner: owner, transaction: $0) }
        update(items: transactionItems)
    }

    func handleError(error: Error) {
        //delegate?.didUpdate(result: .failure(TransactionError.failedToFetch))
        // Avoid showing an error on failed request, instead show cached transactions.
        handleUpdateItems()
    }

    func handleUpdateItems() {
        delegate?.didUpdate(result: .success(storage.objects))
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
    }
}
