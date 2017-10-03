// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import JSONRPCKit
import APIKit
import RealmSwift
import Result

enum TransactionError: Error {
    case failedToFetch
}

protocol TransactionDataCoordinatorDelegate: class {
    func didUpdate(result: Result<[Transaction], TransactionError>)
}

class TransactionDataCoordinator {

    let storage = TransactionsStorage()
    let account: Account
    var viewModel: TransactionsViewModel {
        return .init(transactions: self.storage.objects)
    }
    var timer: Timer?
    weak var delegate: TransactionDataCoordinatorDelegate?

    init(account: Account) {
        self.account = account
    }

    func start() {
        fetchTransactions()
        fetchPendingTransactions()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchPending), userInfo: nil, repeats: true)
    }

    func fetch() {
        fetchTransactions()
    }

    func fetchTransactions() {
        let startBlock: String = {
            guard let transction = storage.objects.first else { return "0" }
            return String(Int(transction.blockNumber) ?? 0 - 20)
        }()

        let request = FetchTransactionsRequest(address: account.address.address, startBlock: startBlock)
        Session.send(request) { result in
            switch result {
            case .success(let response):
                let transactions: [Transaction] = response.map { .from(owner: self.account.address, transaction: $0) }
                self.update(owner: self.account.address, items: transactions)
            case .failure(let error):
                self.handleError(error: error)
            }
        }
    }

    func fetchPendingTransactions() {
        Session.send(EtherServiceRequest(batch: BatchFactory().create(GetBlockByNumberRequest(block: "pending")))) { result in
            switch result {
            case .success(let block):
                for item in block.transactions {
                    if item.to == self.account.address.address || item.from == self.account.address.address {
                        self.update(owner: self.account.address, items: [item])
                    }
                }
            case .failure(let error):
                self.handleError(error: error)
            }
        }
    }

    @objc func fetchPending() {
        fetchPendingTransactions()
    }

    @objc func fetchLatest() {
        fetchTransactions()
    }

    func update(owner: Address, items: [ParsedTransaction]) {
        let transactionItems: [Transaction] = items.map { .from(owner: owner, transaction: $0) }
        update(owner: owner, items: transactionItems)
    }

    func update(owner: Address, items: [Transaction]) {
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
    }
}

extension Transaction {
    static func from(owner: Address, transaction: ParsedTransaction) -> Transaction {
        let state: TransactionState = {
            return .pending
        }()

        return Transaction(
            id: transaction.hash,
            owner: owner.address,
            state: state,
            blockNumber: transaction.blockNumber,
            transactionIndex: transaction.transactionIndex,
            from: transaction.from,
            to: transaction.to,
            value: transaction.value,
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: transaction.gasUsed,
            confirmations: Int64(transaction.confirmations) ?? 0,
            nonce: transaction.nonce,
            date: NSDate(timeIntervalSince1970: TimeInterval(transaction.timestamp) ?? 0) as Date
        )
    }
}

extension Transaction {
    static func from(owner: Address, transaction: EtherScanTransaction) -> Transaction {
        let state: TransactionState = {
            return .pending
        }()

        return Transaction(
            id: transaction.hash,
            owner: owner.address,
            state: state,
            blockNumber: transaction.blockNumber,
            transactionIndex: transaction.transactionIndex,
            from: transaction.from,
            to: transaction.to,
            value: transaction.value,
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: transaction.gasUsed,
            confirmations: Int64(transaction.confirmations) ?? 0,
            nonce: transaction.nonce,
            date: NSDate(timeIntervalSince1970: TimeInterval(transaction.timestamp) ?? 0) as Date
        )
    }
}
