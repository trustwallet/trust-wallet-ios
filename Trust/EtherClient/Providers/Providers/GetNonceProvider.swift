// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit
import BigInt

class GetNonceProvider: NonceProvider {

    let storage: TransactionsStorage
    var remoteNonce: BigInt? = .none
    var latestNonce: BigInt? {
        guard let nonce = storage.latestTransaction?.nonce, let nonceBigInt = BigInt(nonce) else {
            return .none
        }
        let remoteNonceInt = remoteNonce ?? BigInt(-1)
        return max(nonceBigInt, remoteNonceInt)
    }

    var nextNonce: BigInt? {
        guard let latestNonce = latestNonce else {
            return .none
        }
        return latestNonce + 1
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
                self.remoteNonce = count - 1
            case .failure:
                break
            }
        }
    }

    func fetchIfNeeded() {
        if remoteNonce == nil {
            fetch()
        }
    }
}
