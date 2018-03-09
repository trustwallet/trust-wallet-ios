// Copyright SIX DAY LLC. All rights reserved.

import Moya
import TrustKeystore

protocol TransactionsNetworkProtocol: TrustNetworkProtocol {
    func transactions(for address: Address, startBlock: Int, page: Int, completion: @escaping (_ transactions: [Transaction]?) -> Void)
}

class TransactionsNetwork: TransactionsNetworkProtocol {

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
}
