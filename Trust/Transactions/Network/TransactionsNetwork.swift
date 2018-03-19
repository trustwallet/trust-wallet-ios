// Copyright SIX DAY LLC. All rights reserved.

import Moya
import TrustKeystore
import JSONRPCKit
import APIKit
import Result

protocol TransactionsNetworkProtocol: TrustNetworkProtocol {
    func transactions(for address: Address, startBlock: Int, page: Int, completion: @escaping (_ result: ([Transaction]?, Bool)) -> Void)
    func update(for transaction: Transaction, completion: @escaping (_ result: (Transaction, TransactionState)) -> Void)
}

class TransactionsNetwork: TransactionsNetworkProtocol {

    static let deleteMissingInternalSeconds: Double = 60.0

    static let deleyedTransactionInternalSeconds: Double = 60.0

    var provider: MoyaProvider<TrustService>

    var balanceService: TokensBalanceService

    var account: Wallet

    var config: Config

    required init(provider: MoyaProvider<TrustService>, balanceService: TokensBalanceService, account: Wallet, config: Config) {
        self.provider = provider
        self.balanceService = balanceService
        self.account = account
        self.config = config
    }

    func transactions(for address: Address, startBlock: Int, page: Int, completion: @escaping (([Transaction]?, Bool)) -> Void) {
        provider.request(.getTransactions(address: address.description, startBlock: startBlock, page: page)) { result in
            switch result {
            case .success(let response):
                do {
                    let transactions: [Transaction] = try response.map(ArrayResponse<Transaction>.self).docs
                    completion((transactions, true))
                } catch {
                    completion((nil, false))
                }
            case .failure:
                completion((nil, false))
            }
        }
    }

    func update(for transaction: Transaction, completion: @escaping (_ result: (Transaction, TransactionState)) -> Void) {
        let request = GetTransactionRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(batch: BatchFactory().create(request))) { result in
            switch result {
            case .success:
                if transaction.date > Date().addingTimeInterval(TransactionsNetwork.deleyedTransactionInternalSeconds) {
                    completion((transaction, .completed))
                }
            case .failure(let error):
                switch error {
                case .responseError(let error):
                    guard let error = error as? JSONRPCError else { return }
                    switch error {
                    case .responseError:
                        completion((transaction, .deleted))
                    case .resultObjectParseError:
                        if transaction.date > Date().addingTimeInterval(TransactionsNetwork.deleteMissingInternalSeconds) {
                            completion((transaction, .failed))
                        }
                    default: break
                    }
                default: break
                }
            }
        }
    }
}
