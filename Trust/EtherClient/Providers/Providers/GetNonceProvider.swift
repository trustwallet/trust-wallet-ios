// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class GetNonceProvider: NonceProvider {

    let storage: TransactionsStorage

    var latestNonce: Int? {
        guard let nonce = storage.latestTransaction?.nonce else {
            return .none
        }
        return Int(nonce)
    }

    var nextNonce: Int? {
        guard let latestNonce = latestNonce else {
            return .none
        }
        return latestNonce + 1
    }

    func getNonce(for transaction: UnconfirmedTransaction) -> Int {
        guard let nonce = transaction.nonce else {
            return nextNonce ?? -1
        }
        return Int(nonce)
    }

    init(
        storage: TransactionsStorage
    ) {
        self.storage = storage
    }
}
