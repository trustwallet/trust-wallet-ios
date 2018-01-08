// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import APIKit
import JSONRPCKit
import Result

struct SentTransaction {
    let id: String
}

class SendTransactionCoordinator {

    private let keystore: Keystore
    let config = Config()
    let session: WalletSession
    let formatter = EtherNumberFormatter.full

    init(
        session: WalletSession,
        keystore: Keystore
    ) {
        self.session = session
        self.keystore = keystore
    }

    func send(
        transactions: [SignTransaction],
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: session.account.address.description)))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                let transactions = self.mergeNonce(transactions: transactions, currentNonce: count)
                guard let first = transactions.first else { return }
                self.signAndSend(transaction: first, completion: completion)
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    private func mergeNonce(transactions: [SignTransaction], currentNonce: Int) -> [SignTransaction] {
        return transactions.map { appendNonce(to: $0, currentNonce: currentNonce) }
    }

    private func appendNonce(to: SignTransaction, currentNonce: Int) -> SignTransaction {
        return SignTransaction(
            value: to.value,
            account: to.account,
            address: to.address,
            nonce: currentNonce,
            data: to.data,
            gasPrice: to.gasPrice,
            gasLimit: to.gasLimit,
            chainID: to.chainID
        )
    }

//    func send(
//        contract: Address,
//        to: Address,
//        amount: BigInt,
//        configuration: TransactionConfiguration,
//        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
//    ) {
//        session.web3.request(request: ContractERC20Transfer(amount: amount, address: to.address)) { result in
//            switch result {
//            case .success(let res):
//                self.send(
//                    address: contract,
//                    value: 0,
//                    data: Data(hex: res.drop0x),
//                    configuration: configuration,
//                    completion: completion
//                )
//            case .failure(let error):
//                completion(.failure(AnyError(error)))
//            }
//        }
//    }

    func signAndSend(
        transaction: SignTransaction,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let signedTransaction = keystore.signTransaction(transaction)

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
//
//    func trade(
//        from: SubmitExchangeToken,
//        to: SubmitExchangeToken,
//        configuration: TransactionConfiguration,
//        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
//    ) {
//        let exchangeConfig = ExchangeConfig(server: config.server)
//        let needsApproval: Bool = {
//            return from.token.address != exchangeConfig.tokenAddress
//        }()
//        let tradeNonce: Int = {
//            return needsApproval ? 1 : 0
//        }()
//
//        let value = from.amount
//
//        // approve amount
//        if needsApproval {
//            // ApproveERC20Encode
//            let approveRequest = ApproveERC20Encode(address: exchangeConfig.contract, value: value)
//            session.web3.request(request: approveRequest) { result in
//                switch result {
//                case .success(let res):
////                    self.send(
////                        address: from.token.address,
////                        value: 0,
////                        data: Data(hex: res.drop0x),
////                        configuration: configuration,
////                        completion: completion
////                    )
//                    self.makeTrade(from: from, to: to, value: value, configuration: configuration, tradeNonce: tradeNonce, completion: completion)
//                case .failure(let error):
//                    completion(.failure(AnyError(error)))
//                }
//            }
//        } else {
//            self.makeTrade(from: from, to: to, value: value, configuration: configuration, tradeNonce: tradeNonce, completion: completion)
//        }
//
//        //Execute trade request
//    }
//
//    private func makeTrade(
//        from: SubmitExchangeToken,
//        to: SubmitExchangeToken,
//        value: BigInt,
//        configuration: TransactionConfiguration,
//        tradeNonce: Int,
//        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
//    ) {
//        let exchangeConfig = ExchangeConfig(server: config.server)
//        let etherValue: BigInt = {
//            // if ether - pass actual value
//            return from.token.symbol == config.server.symbol ? from.amount : BigInt(0)
//        }()
//        let source = from.token.address
//        let dest = to.token.address
//        let destAddress: Address = session.account.address
//
//        let request = ContractExchangeTrade(
//            source: source.address,
//            value: value,
//            dest: dest.address,
//            destAddress: destAddress.address,
//            maxDestAmount: "100000000000000000000000000000000000000000000000000000000000000000000000000000",
//            minConversionRate: 1,
//            throwOnFailure: true,
//            walletId: "0x00"
//        )
//        session.web3.request(request: request) { result in
//            switch result {
//            case .success(let res):
//                NSLog("result \(res)")
////                self.send(
////                    address: exchangeConfig.contract,
////                    value: etherValue,
////                    data: Data(hex: res.drop0x),
////                    extraNonce: tradeNonce,
////                    configuration: configuration,
////                    completion: completion
////                )
//            case .failure(let error):
//                completion(.failure(AnyError(error)))
//            }
//        }
//    }
}
