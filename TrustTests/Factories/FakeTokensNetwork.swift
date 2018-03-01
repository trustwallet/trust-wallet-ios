// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya
@testable import Trust

class FakeTokensNetwork: TokensNetworkProtocol {
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
    
    func tickers(for tokens: [TokenObject], completion: @escaping ([CoinTicker]?) -> Void) {
        //Implement mock
    }
    
    func ethBalance(completion: @escaping (Balance?) -> Void) {
        //Implement mock
    }
    
    func tokenBalance(for token: TokenObject, completion: @escaping ((TokenObject, Balance?)) -> Void) {
        //Implement mock
    }
    
}
