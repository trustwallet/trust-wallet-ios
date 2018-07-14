// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Moya
@testable import Trust
import BigInt
import TrustCore
import TrustKeystore
import Result
import PromiseKit
import enum Result.Result

enum FakeTokensNetworkError: Error {
    case notImplmented
}

class FakeTokensNetwork: NetworkProtocol {

    var provider: MoyaProvider<TrustService>
    var APIProvider: MoyaProvider<TrustAPI>
    var balanceService: TokensBalanceService
    var account: Trust.WalletInfo
    var config: Config
    
    required init(provider: MoyaProvider<TrustService>, APIProvider: MoyaProvider<TrustAPI>, balanceService: TokensBalanceService, account: Trust.WalletInfo, config: Config) {
        self.provider = provider
        self.APIProvider = APIProvider
        self.balanceService = balanceService
        self.account = account
        self.config = config
    }
    
    func tickers(for tokens: [TokenObject], completion: @escaping ([CoinTicker]?) -> Void) {
        let ticker = CoinTicker(
            symbol: "ETH",
            price: "100",
            percent_change_24h: "-2.39",
            contract: config.server.address,
            tickersKey: "tickersKey")
        completion([ticker])
    }

    func assets() -> Promise<[NonFungibleTokenCategory]> {
        return Promise { seal in
            seal.reject(FakeTokensNetworkError.notImplmented)
        }
    }

    func tokensList(for address: Address, completion: @escaping (([TokenObject]?)) -> Void) {

    }

    func transactions(for address: Address, startBlock: Int, page: Int, contract: String?, completion: @escaping (([Trust.Transaction]?, Bool)) -> Void) {
        
    }

    func update(for transaction: Trust.Transaction, completion: @escaping (Result<(Trust.Transaction, TransactionState), AnyError>) -> Void) {
        
    }

    func search(token: String, completion: @escaping (([TokenObject]) -> Void)) {
        completion([])
    }

    func tickers(with tokenPrices: [TokenPrice], completion: @escaping ([CoinTicker]?) -> Void) {

    }

    func tokenBalance(for contract: Address, completion: @escaping (Balance?) -> Void) {
        completion(Balance(value: BigInt(100)))
    }

    func tickers(with tokenPrices: [TokenPrice]) -> Promise<[CoinTicker]> {
        return Promise { seal in
            let ticker = CoinTicker(symbol: "ETH", price: "100", percent_change_24h: "-2.39", contract: config.server.address)
            seal.fulfill([ticker])
        }
    }

    func ethBalance() -> Promise<Balance> {
        return Promise { seal in
            seal.fulfill(Balance(value: BigInt(100)))
        }
    }

    func tokensList(for address: Address) -> Promise<[TokenObject]> {
        return Promise { seal in
           let token = TokenObject(contract: "0xe41d2489571d322189246dafa5ebde1f4699f498", name: "0x project", symbol: "ZRX", decimals: 18, value: "39330812000000000000000", isCustom: true, isDisabled: false)
            seal.fulfill([token])
        }
    }

    func search(token: String) -> Promise<TokenObject> {
        return Promise { seal in
            let token = TokenObject(contract: "0xe41d2489571d322189246dafa5ebde1f4699f498", name: "0x project", symbol: "ZRX", decimals: 18, value: "39330812000000000000000", isCustom: true, isDisabled: false)
            seal.fulfill(token)
        }
    }
}
