// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit
import BigInt
import Result
import TrustCore

final class GetNonceProvider: NonceProvider {
    let storage: TransactionsStorage
    let server: RPCServer
    let address: Address
    var remoteNonce: BigInt? = .none
    var latestNonce: BigInt? {
        guard let nonce = storage.latestTransaction(for: address, coin: server.coin)?.nonce else {
            return .none
        }
        let remoteNonceInt = remoteNonce ?? BigInt(-1)
        return max(BigInt(nonce), remoteNonceInt)
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
        storage: TransactionsStorage,
        server: RPCServer,
        address: Address
    ) {
        self.storage = storage
        self.server = server
        self.address = address

        fetchLatestNonce()
    }

    func fetchLatestNonce() {
        fetch { _ in }
    }

    func getNextNonce(force: Bool = false, completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        guard let nextNonce = nextNonce, force == false else {
            return fetchNextNonce(completion: completion)
        }
        completion(.success(nextNonce))
    }

    func fetchNextNonce(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        fetch { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let nonce):
                let res = self.nextNonce ?? nonce + 1
                completion(.success(res))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetch(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        let request = EtherServiceRequest(for: server, batch: BatchFactory().create(GetTransactionCountRequest(
            address: address.description,
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
