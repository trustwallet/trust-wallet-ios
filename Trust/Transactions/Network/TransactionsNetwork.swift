// Copyright SIX DAY LLC. All rights reserved.

import Moya
import TrustKeystore
import JSONRPCKit
import APIKit
import Result

protocol TransactionsNetworkProtocol: TrustNetworkProtocol {
    func transactions(for address: Address, startBlock: Int, page: Int, completion: @escaping (_ transactions: [Transaction]?) -> Void)
    func update(for transaction: Transaction, completion: @escaping (_ result:([Transaction], TransactionState)) -> Void)
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

    func transactions(for address: Address, startBlock: Int, page: Int, completion: @escaping ([Transaction]?) -> Void) {
        provider.request(.getTransactions(address: address.description, startBlock: startBlock, page: page)) { result in
            switch result {
            case .success(let response):
                do {
                    let rawTransactions = try response.map(ArrayResponse<RawTransaction>.self).docs
                    let transactions: [Transaction] = rawTransactions.flatMap { .from(transaction: $0) }
                    completion(transactions)
                } catch {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }

    func update(for transaction: Transaction, completion: @escaping (_ result:([Transaction], TransactionState)) -> Void) {
        let request = GetTransactionRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(batch: BatchFactory().create(request))) { result in
            switch result {
            case .success(_):
                if transaction.date > Date().addingTimeInterval(TransactionsNetwork.deleyedTransactionInternalSeconds) {
                    completion(([transaction], .completed))
                }
            case .failure(let error):
                switch error {
                case .responseError(let error):
                    guard let error = error as? JSONRPCError else { return }
                    switch error {
                    case .responseError(_,_,_):
                        completion(([transaction], .deleted))
                    case .resultObjectParseError:
                        if transaction.date > Date().addingTimeInterval(TransactionsNetwork.deleteMissingInternalSeconds) {
                            completion(([transaction], .failed))
                        }
                    default: break
                    }
                default: break
                }
            }
        }
    }
}
