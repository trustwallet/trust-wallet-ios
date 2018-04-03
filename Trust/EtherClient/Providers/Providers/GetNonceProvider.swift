// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit

class GetNonceProvider: NonceProvider {

    let storage: TransactionsStorage
    var remoteNonce: Int? = .none
    var latestNonce: Int? {
        guard let nonce = storage.latestTransaction?.nonce, let nonceInt = Int(nonce) else {
            return .none
        }
        let remoteNonceInt = remoteNonce ?? -1
        return max(nonceInt, remoteNonceInt)
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

        fetch()
    }

    func fetch() {
        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
            address: storage.account.address.description,
            state: "latest"
        )))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                self.remoteNonce = count
            case .failure: break
            }
        }
    }

    func fetchIfNeeded() {
        if remoteNonce == nil {
            fetch()
        }
    }
}
