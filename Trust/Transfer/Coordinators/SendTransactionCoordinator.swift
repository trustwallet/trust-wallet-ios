// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth
import APIKit
import JSONRPCKit
import Result

struct SentTransaction {
    let id: String
}

class SendTransactionCoordinator {

    let keystore = EtherKeystore()
    let config = Config()
    let account: Account

    init(
        account: Account
    ) {
        self.account = account
    }

    func send(
        address: Address,
        value: Double,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let amountDouble = BDouble(floatLiteral: value) * BDouble(integerLiteral: EthereumUnit.ether.rawValue)
        let amount = GethBigInt.from(double: amountDouble)

        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: account.address.address)))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                self.sign(address: address, nonce: count, amount: amount, configuration: configuration, completion: completion)
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    func sign(
        address: Address,
        nonce: Int64 = 0,
        amount: GethBigInt,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let signedTransaction = keystore.signTransaction(
            amount: amount,
            account: account,
            address: address,
            nonce: nonce,
            speed: configuration.speed,
            chainID: GethBigInt.from(int: config.chainID)
        )

        switch signedTransaction {
        case .success(let data):
            let sendData = data.hexEncoded
            let request = EtherServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: sendData)))
            Session.send(request) { result in
                switch result {
                case .success(let transactionID):
                    completion(.success(SentTransaction(id: transactionID)))
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
}
