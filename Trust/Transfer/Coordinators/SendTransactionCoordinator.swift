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
    let session: WalletSession

    init(
        session: WalletSession
    ) {
        self.session = session
    }

    func send(
        address: Address,
        value: Double,
        data: Data = Data(),
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let amountDouble = BDouble(floatLiteral: value) * BDouble(integerLiteral: EthereumUnit.ether.rawValue)
        let amount = GethBigInt.from(double: amountDouble)

        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: session.account.address.address)))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                self.sign(address: address, nonce: count, amount: amount, data: data, configuration: configuration, completion: completion)
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    func send(
        contract: Address,
        to: Address,
        amount: Double,
        decimals: Int64,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        //let contract = "0x47c5a08256065306216b3e7cd82b599937540d1f"
        //let to = "0x0039f22efb07a647557c7c5d17854cfd6d489ef3"

        session.web3.request(request: ContractERC20Transfer(amount: amount, decimals: decimals, address: to.address)) { result in
            switch result {
            case .success(let res):

                NSLog("result \(res)")

                self.send(
                    address: contract,
                    value: 0,
                    data: Data(hex: res.drop0x),
                    configuration: TransactionConfiguration(
                        speed: TransactionSpeed.custom(
                            gasPrice: TransactionSpeed.regular.gasPrice,
                            gasLimit: GethNewBigInt(2900000)
                        )
                    ),
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    func sign(
        address: Address,
        nonce: Int64 = 0,
        amount: GethBigInt,
        data: Data,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let signedTransaction = keystore.signTransaction(
            amount: amount,
            account: session.account,
            address: address,
            nonce: nonce,
            speed: configuration.speed,
            data: data,
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
