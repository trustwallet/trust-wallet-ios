// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import APIKit
import JSONRPCKit
import Result

class SendTransactionCoordinator {

    private let keystore: Keystore
    let config = Config()
    let session: WalletSession
    let formatter = EtherNumberFormatter.full
    let confirmType: ConfirmType

    init(
        session: WalletSession,
        keystore: Keystore,
        confirmType: ConfirmType
    ) {
        self.session = session
        self.keystore = keystore
        self.confirmType = confirmType
    }

    func send(
        transaction: SignTransaction,
        completion: @escaping (Result<ConfirmResult, AnyError>) -> Void
    ) {
        if transaction.nonce >= 0 {
            signAndSend(transaction: transaction, completion: completion)
        } else {
            let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
                address: session.account.address.description,
                state: "pending"
            )))
            Session.send(request) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let count):
                    let transaction = self.appendNonce(to: transaction, currentNonce: count)
                    self.signAndSend(transaction: transaction, completion: completion)
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }

    private func appendNonce(to: SignTransaction, currentNonce: Int) -> SignTransaction {
        return SignTransaction(
            value: to.value,
            account: to.account,
            to: to.to,
            nonce: currentNonce,
            data: to.data,
            gasPrice: to.gasPrice,
            gasLimit: to.gasLimit,
            chainID: to.chainID
        )
    }

    func signAndSend(
        transaction: SignTransaction,
        completion: @escaping (Result<ConfirmResult, AnyError>) -> Void
    ) {
        let signedTransaction = keystore.signTransaction(transaction)

        switch signedTransaction {
        case .success(let data):
            let transaction = SentTransaction(
                id: data.sha3(.keccak256).hexEncoded,
                original: transaction,
                data: data
            )
            switch confirmType {
            case .sign:
                completion(.success(.signedTransaction(transaction)))
            case .signThenSend:
                let request = EtherServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: data.hexEncoded)))
                Session.send(request) { result in
                    switch result {
                    case .success:
                        completion(.success(.sentTransaction(transaction)))
                    case .failure(let error):
                        completion(.failure(AnyError(error)))
                    }
                }
            }
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
}
