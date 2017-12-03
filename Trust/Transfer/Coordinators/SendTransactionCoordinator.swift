// Copyright SIX DAY LLC. All rights reserved.

import BigInt
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
        extraNonce: Int = 0,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let amountDouble = value * Double(EthereumUnit.ether.rawValue)
        let amount = BigInt(amountDouble)

        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: session.account.address.address)))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                let nonce = count + extraNonce
                self.sign(address: address, nonce: nonce, amount: amount, data: data, configuration: configuration, completion: completion)
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
        let amountToSend = (amount * pow(10, decimals).doubleValue).description
        session.web3.request(request: ContractERC20Transfer(amount: amountToSend, address: to.address)) { result in
            switch result {
            case .success(let res):
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
        nonce: Int = 0,
        amount: BigInt,
        data: Data,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let signTransaction = SignTransaction(
            amount: amount.gethBigInt,
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
        from: SubmitExchangeToken,
        to: SubmitExchangeToken,
        configuration: TransactionConfiguration,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let exchangeConfig = ExchangeConfig(server: config.server)
        let needsApproval: Bool = {
            return from.token.address != exchangeConfig.tokenAddress
        }()
        let tradeNonce: Int = {
            return needsApproval ? 1 : 0
        }()

        let amountToSend = (from.amount * pow(10, from.token.decimals).doubleValue).description

        // approve amount
        if needsApproval {
            // ApproveERC20Encode
            let approveRequest = ApproveERC20Encode(address: exchangeConfig.contract, amount: amountToSend)
            session.web3.request(request: approveRequest) { result in
                switch result {
                case .success(let res):
                    self.send(
                        address: from.token.address,
                        value: 0,
                        data: Data(hex: res.drop0x),
                        configuration: configuration,
                        completion: completion
                    )
                    self.makeTrade(from: from, to: to, amountToSend: amountToSend, configuration: configuration, tradeNonce: tradeNonce, completion: completion)
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        } else {
            self.makeTrade(from: from, to: to, amountToSend: amountToSend, configuration: configuration, tradeNonce: tradeNonce, completion: completion)
        }

        //Execute trade request
    }

    private func makeTrade(
        from: SubmitExchangeToken,
        to: SubmitExchangeToken,
        amountToSend: String,
        configuration: TransactionConfiguration,
        tradeNonce: Int,
        completion: @escaping (Result<SentTransaction, AnyError>) -> Void
    ) {
        let exchangeConfig = ExchangeConfig(server: config.server)
        let value: Double = {
            // if ether - pass actual value
            return from.token.symbol == config.server.symbol ? from.amount : 0
        }()
        let source = from.token.address
        let dest = to.token.address
        let destAddress: Address = session.account.address

        let request = ContractExchangeTrade(
            source: source.address,
            amount: amountToSend,
            dest: dest.address,
            destAddress: destAddress.address,
            maxDestAmount: "100000000000000000000000000000000000000000000000000000000000000000000000000000",
            minConversionRate: 1,
            throwOnFailure: true,
            walletId: "0x00"
        )
        session.web3.request(request: request) { result in
            switch result {
            case .success(let res):
                NSLog("result \(res)")
                self.send(
                    address: exchangeConfig.contract,
                    value: value,
                    data: Data(hex: res.drop0x),
                    extraNonce: tradeNonce,
                    configuration: configuration,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
