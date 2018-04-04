// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit
import BigInt
import Result

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

    var nonceAvailable: Bool {
        return latestNonce != nil
    }

    init(
        storage: TransactionsStorage
    ) {
        self.storage = storage

        fetchLatestNonce()
    }

    func fetchLatestNonce() {
        fetch { _ in }
    }

    func getNextNonce(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        guard let nextNonce = nextNonce else {
            return fetch(completion: completion)
        }
        completion(.success(nextNonce))
    }

    func fetch(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
            address: storage.account.address.description,
            state: "latest"
        )))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                let nonce = count - 1
                self.remoteNonce = nonce
                completion(.success(nonce))
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
