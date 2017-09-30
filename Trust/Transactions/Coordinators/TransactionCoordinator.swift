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

enum TokenError: Error {
    case failedToFetch
}

protocol TransactionCoordinatorDelegate: class {
    func didUpdate(result: Result<[Transaction], TransactionError>)
}

class TransactionCoordinator {

    let storage = TransactionsStorage()
    let account: Account

    var viewModel: TransactionsViewModel {
        return .init(transactions: self.storage.objects)
    }

    weak var delegate: TransactionCoordinatorDelegate?
    var timer: Timer?
    //let notificationToken: NotificationToken

    init(account: Account) {
        self.account = account

        storage.deleteAll()

//        notificationToken = storage.realm.addNotificationBlock { item, _ in
//            switch item {
//            case .didChange: break
//            case .refreshRequired: break
//            }
//        }

    }

    func start() {
        fetchTransactions()

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.timerTrigger), userInfo: nil, repeats: true)
    }

    func fetchTransactions() {
        let request = FetchTransactionsRequest(address: account.address.address)
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.update(owner: self.account.address, items: response)
            case .failure:
                break
            }
        }
    }

    func fetchPendingTransactions() {
        Session.send(EtherServiceRequest(batch: BatchFactory().create(BlockNumberRequest()))) { result in
            switch result {
            case .success(let blockNumber):
                Session.send(EtherServiceRequest(batch: BatchFactory().create(GetBlockByNumberRequest(block: blockNumber, includeTransactions: true)))) { result in
                    switch result {
                    case .success(let transactions):
                        NSLog("transactions \(transactions)")
                    case .failure:
                        break
                    }
                }
            case .failure:
                break
            }
        }
    }
    @objc func timerTrigger() {
        fetchPendingTransactions()
    }

    func update(owner: Address, items: [ParsedTransaction]) {
        let transactionItems: [Transaction] = items.map { .from(owner: owner, transaction: $0) }
        storage.add(transactionItems)
        print()

        delegate?.didUpdate(result: .success(self.storage.objects))
    }

    func print() {
        NSLog("objects \(storage.objects)")
    }

    func stop() {
        //notificationToken.stop()
    }
}

extension Transaction {
    static func from(owner: Address, transaction: ParsedTransaction) -> Transaction {
        let state: TransactionState = {
            return .pending
        }()

        return Transaction(
            id: transaction.hash,
            owner: owner.address, //TODO
            state: state,
            blockNumber: transaction.blockNumber,
            from: transaction.from,
            to: transaction.to,
            value: transaction.value, //TODO
            gas: transaction.gas,
            gasPrice: transaction.gasPrice,
            gasUsed: transaction.gasUsed,
            confirmations: Int64(transaction.confirmations) ?? 0,
            nonce: "0", // TODO
            date: NSDate(timeIntervalSince1970: TimeInterval(transaction.timestamp) ?? 0) as Date
        )
    }

//    static func from(address: String, json: [String: AnyObject]) -> Transaction {
//        let blockHash = json["blockHash"] as? String ?? ""
//        let blockNumber = json["blockNumber"] as? String ?? ""
//        let confirmation = json["confirmations"] as? String ?? ""
//        let cumulativeGasUsed = json["cumulativeGasUsed"] as? String ?? ""
//        let from = json["from"] as? String ?? ""
//        let to = json["to"] as? String ?? ""
//        let gas = json["gas"] as? String ?? ""
//        let gasPrice = json["gasPrice"] as? String ?? ""
//        let gasUsed = json["gasUsed"] as? String ?? ""
//        let hash = json["hash"] as? String ?? ""
//        let isError = Bool(json["isError"] as? String ?? "") ?? false
//        let timestamp = (json["timeStamp"] as? String ?? "")
//        let value = (json["value"] as? String ?? "")
//
//        let state: TransactionState = {
//            return .pending
//        }()
//
//        return Transaction(
//            id: hash,
//            state: state,
//            blockNumber: blockNumber,
//            from: from,
//            to: to,
//            value: "0x0", //TODO
//            gas: gas,
//            gasPrice: gasPrice,
//            confirmations: Int64(confirmations) ?? 0,
//            nonce: "0x0", // TODO
//            date: NSDate(timeIntervalSince1970: TimeInterval(timestamp) ?? 0) as Date
//        )
//    }
}
