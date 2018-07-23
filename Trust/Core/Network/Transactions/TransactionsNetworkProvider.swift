// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Result

protocol TransactionsNetworkProvider {
    func update(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void)
}
