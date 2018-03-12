// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya
@testable import Trust
import BigInt
import TrustKeystore

class FakeTokensNetwork: TokensNetworkProtocol {

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
        let rate = Rate(code: "ETH", price: 100.0, contract: eth_contract)
        let ticker = CoinTicker(id: "ethereum", symbol: "ETH", price: "800", percent_change_24h: "-2.39", contract: eth_contract, image: "https://files.coinmarketcap.com/static/img/coins/128x128/ethereum.png", rate: CurrencyRate(currency: "USD", rates: [rate]))
        completion([ticker])
    }
    
    func ethBalance(completion: @escaping (Balance?) -> Void) {
        completion(Balance(value: BigInt(100)))
    }
    
    func tokenBalance(for token: TokenObject, completion: @escaping ((TokenObject, Balance?)) -> Void) {
        completion((token, Balance(value: BigInt(400))))
    }

    func assets(completion: @escaping (([NonFungibleTokenCategory]?)) -> Void) {
        
    }

    func tokensList(for address: TrustKeystore.Address, completion: @escaping (([TokenListItem]?)) -> Void) {

    }
}
