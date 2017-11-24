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
        let amountDouble = BDouble(floatLiteral: value) * BDouble(Double(EthereumUnit.ether.rawValue) ?? 0)
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
        decimals: Int,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let amountToSend = (BDouble(floatLiteral: amount) * BDouble(pow(10, decimals).doubleValue)).description
        session.web3.request(request: ContractERC20Transfer(amount: amountToSend, address: to.address)) { result in
            switch result {
            case .success(let res):
                NSLog("result \(res)")
                self.send(
                    address: contract,
                    value: 0,
                    data: Data(hex: res.drop0x),
                    configuration: configuration,
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
        let signTransaction = SignTransaction(
            amount: amount,
            account: session.account,
            address: address,
            nonce: nonce,
            speed: configuration.speed,
            data: data,
            chainID: GethBigInt.from(int: config.chainID)
        )
        let signedTransaction = keystore.signTransaction(signTransaction)

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

    func trade(
        contract: Address,
        from: SubmitExchangeToken,
        to: SubmitExchangeToken,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let request = ContractExchangeTrade(
            source: from.token.address.address,
            amount: String(100000),
            dest: to.token.address.address,
            destAddress: session.account.address.address,
            maxDestAmount: "9999999",
            minConversionRate: 1,
            throwOnFailure: false,
            walletId: "0x00"
        )
        session.web3.request(request: request) { result in
            switch result {
            case .success(let res):
                NSLog("result \(res)")
                self.send(
                    address: contract,
                    value: 1,
                    data: Data(hex: res.drop0x),
                    configuration: configuration,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
