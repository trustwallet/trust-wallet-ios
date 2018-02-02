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

    struct Config {
        static let deleteMissingInternalSeconds: Double = 60.0
        static let deleyedTransactionInternalSeconds: Double = 60.0
    }

    let storage: TransactionsStorage
    let session: WalletSession
    let config = Config()
    var viewModel: TransactionsViewModel {
        return .init(transactions: self.storage.objects)
    }
    var timer: Timer?
    var updateTransactionsTimer: Timer?

    weak var delegate: TransactionDataCoordinatorDelegate?
    private lazy var transactionsTracker: TransactionsTracker = {
        return TransactionsTracker(sessionID: session.sessionID)
    }()
    private let trustProvider = TrustProviderFactory.makeProvider()

    init(
        session: WalletSession,
        storage: TransactionsStorage
    ) {
        self.session = session
        self.storage = storage
    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: BlockOperation { [weak self] in
            self?.fetchPending()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
        updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 15, target: BlockOperation { [weak self] in
            self?.fetchTransactions()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)

        // Start fetching all transactions process.
        if transactionsTracker.fetchingState != .done {
            initialFetch(for: session.account.address, page: 0) { _ in }
        }
    }

    func fetch() {
        session.refresh(.balance)
        fetchTransactions()
        fetchPendingTransactions()
    }

    @objc func fetchTransactions() {
        let startBlock: Int = {
            guard let transaction = storage.completedObjects.first else { return 1 }
            return transaction.blockNumber - 2000
        }()
        fetchTransaction(
            for: session.account.address,
            startBlock: startBlock
        ) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let transactions):
                self.update(items: transactions)
            case .failure(let error):
                self.handleError(error: error)
            }
        }
    }

    private func fetchTransaction(
        for address: Address,
        startBlock: Int,
        page: Int = 0,
        completion: @escaping (Result<[Transaction], AnyError>) -> Void
    ) {
        NSLog("fetchTransaction: startBlock: \(startBlock), page: \(page)")

        trustProvider.request(.getTransactions(address: address.description, startBlock: startBlock, page: page)) { result in
            switch result {
            case .success(let response):
                do {
                    let rawTransactions = try response.map(ArrayResponse<RawTransaction>.self).docs
                    let transactions: [Transaction] = rawTransactions.flatMap { .from(transaction: $0) }
                    completion(.success(transactions))
                } catch {
                    completion(.failure(AnyError(error)))
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    func update(items: [PendingTransaction]) {
        let transactionItems: [Transaction] = items.flatMap { .from(transaction: $0) }
        update(items: transactionItems)
    }

    func fetchPendingTransactions() {
        storage.pendingObjects.forEach { updatePendingTransaction($0) }
    }

    private func updatePendingTransaction(_ transaction: Transaction) {
        let request = GetTransactionRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(batch: BatchFactory().create(request))) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let parsedTransaction):
                // NSLog("parsedTransaction \(parsedTransaction)")
                if transaction.date > Date().addingTimeInterval(Config.deleyedTransactionInternalSeconds) {
                    self.update(state: .completed, for: transaction)
                    self.update(items: [transaction])
                }
            case .failure(let error):
                // NSLog("error: \(error)")
                switch error {
                case .responseError(let error):
                    // TODO: Think about the logic to handle pending transactions.
                    guard let error = error as? JSONRPCError else { return }
                    switch error {
                    case .responseError(let code, let message, _):
                        // NSLog("code \(code), error: \(message)")
                        self.delete(transactions: [transaction])
                    case .resultObjectParseError:
                        if transaction.date > Date().addingTimeInterval(Config.deleteMissingInternalSeconds) {
                            self.update(state: .failed, for: transaction)
                        }
                    default: break
                    }
                default: break
                }
            }
        }
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
        //delegate?.didUpdate(result: .failure(TransactionError.failedToFetch))
        // Avoid showing an error on failed request, instead show cached transactions.
        handleUpdateItems()
    }

    func handleUpdateItems() {
        delegate?.didUpdate(result: .success(storage.objects))
    }

    func addSentTransaction(_ transaction: SentTransaction) {
        let transaction = SentTransaction.from(from: session.account.address, transaction: transaction)
        storage.add([transaction])
        handleUpdateItems()
    }

    func update(state: TransactionState, for transaction: Transaction) {
        storage.update(state: state, for: transaction)
        handleUpdateItems()
    }

    func delete(transactions: [Transaction]) {
        storage.delete(transactions)
        handleUpdateItems()
    }

    func initialFetch(
        for address: Address,
        page: Int,
        completion: @escaping (Result<[Transaction], AnyError>) -> Void
    ) {
        fetchTransaction(for: address, startBlock: 1, page: page) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let transactions):
                self.update(items: transactions)
                if !transactions.isEmpty && page <= 50 { // page limit to 50, otherwise you have too many transactions.
                    self.initialFetch(for: address, page: page + 1, completion: completion)
                } else {
                    self.transactionsTracker.fetchingState = .done
                }
            case .failure:
                self.transactionsTracker.fetchingState = .failed
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
    }
}
