// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Result
import APIKit
import JSONRPCKit

class EthereumTransactionsProvider: TransactionsNetworkProvider {

    let server: RPCServer

    init(
        server: RPCServer
    ) {
        self.server = server
    }

    func update(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void) {
        let request = GetTransactionRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(for: server, batch: BatchFactory().create(request))) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let tx):
                guard let newTransaction = Transaction.from(initialTransaction: transaction, transaction: tx, coin: self.server.coin) else {
                    return completion(.success((transaction, .pending)))
                }
                if newTransaction.blockNumber > 0 {
                    self.getReceipt(for: newTransaction, completion: completion)
                }
            case .failure(let error):
                switch error {
                case .responseError(let error):
                    guard let error = error as? JSONRPCError else { return }
                    switch error {
                    case .responseError:
                        if transaction.date > Date().addingTimeInterval(TrustNetwork.deleteMissingInternalSeconds) {
                            completion(.success((transaction, .deleted)))
                        }
                    case .resultObjectParseError:
                        if transaction.date > Date().addingTimeInterval(TrustNetwork.deleteMissingInternalSeconds) {
                            completion(.success((transaction, .failed)))
                        }
                    default: break
                    }
                default: break
                }
            }
        }
    }

    private func getReceipt(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void) {
        let request = GetTransactionReceiptRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(for: server, batch: BatchFactory().create(request))) { result in
            switch result {
            case .success(let receipt):
                let newTransaction = transaction
                newTransaction.gasUsed = receipt.gasUsed
                let state: TransactionState = receipt.status ? .completed : .failed
                completion(.success((newTransaction, state)))
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
