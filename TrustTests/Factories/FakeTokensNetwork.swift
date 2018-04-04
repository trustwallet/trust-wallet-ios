// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya
@testable import Trust
import BigInt
import TrustCore
import TrustKeystore

class FakeTokensNetwork: NetworkProtocol {
    var provider: MoyaProvider<TrustService>
    var balanceService: TokensBalanceService
    var account: Trust.Wallet
    var config: Config
    
    required init(provider: MoyaProvider<TrustService>, balanceService: TokensBalanceService, account: Trust.Wallet, config: Config) {
        self.provider = provider
        self.balanceService = balanceService
        self.account = account
        self.config = config
    }
    
    func tickers(for tokens: [TokenObject], completion: @escaping ([CoinTicker]?) -> Void) {
        let eth_contract = "0x0000000000000000000000000000000000000000"
        let ticker = CoinTicker(id: "ethereum", symbol: "ETH", price: "100", percent_change_24h: "-2.39", contract: eth_contract, image: "https://files.coinmarketcap.com/static/img/coins/128x128/ethereum.png")
        completion([ticker])
    }

    func assets(completion: @escaping (([NonFungibleTokenCategory]?)) -> Void) {
        
    }

    func tokensList(for address: Address, completion: @escaping (([TokenObject]?)) -> Void) {

    }

    func transactions(for address: Address, startBlock: Int, page: Int, contract: String?, completion: @escaping (([Trust.Transaction]?, Bool)) -> Void) {
        
    }

    func update(for transaction: Trust.Transaction, completion: @escaping ((Trust.Transaction, TransactionState)) -> Void) {
        
    }

    func search(token: String, completion: @escaping (([TokenObject]) -> Void)) {
        completion([])
    }

    func tickers(with tokenPrices: [TokenPrice], completion: @escaping ([CoinTicker]?) -> Void) {

    }

    func tokenBalance(for contract: Address, completion: @escaping (Balance?) -> Void) {
        completion(Balance(value: BigInt(100)))
    }
}
