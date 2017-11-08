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

    private let trustProvider = MoyaProvider<TrustService>()
    private let etherscanProvider = MoyaProvider<EtherscanService>()

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
            return transction.blockNumber - 2000
        }()

        etherscanProvider.request(.transactions(address: account.address.address, startBlock: startBlock, endBlock: 999999999)) { result in
            switch result {
            case .success(let response):
                do {
                    let transactions = try response.map(EtherscanArrayResponse<EtherscanTransaction>.self).result
                    let chainID = self.config.chainID
                    let transactions2: [Transaction] = transactions.map { .from(
                        chainID: chainID,
                        owner: self.account.address,
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
        func fetchPendingTransactions() {
            Session.send(EtherServiceRequest(batch: BatchFactory().create(GetBlockByNumberRequest(block: "pending")))) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let block):
                    for item in block.transactions {
                        if item.to == self.account.address.address || item.from == self.account.address.address {
                            self.update(chainID: self.config.chainID, owner: self.account.address, items: [item])
                        }
                    }
                case .failure(let error):
                    self.handleError(error: error)
                }
            }
        }
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

    func update(chainID: Int, owner: Address, items: [ParsedTransaction]) {
        let transactionItems: [Transaction] = items.map { .from(chainID: chainID, owner: owner, transaction: $0) }
        update(items: transactionItems)
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
