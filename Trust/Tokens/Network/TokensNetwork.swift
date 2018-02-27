// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Moya
import TrustKeystore

protocol TrustNetworkProtocol {
    var provider: MoyaProvider<TrustService> { get }
    var balanceService: TokensBalanceService { get }
    var account: Account { get }
    var config: Config { get }
    init(provider: MoyaProvider<TrustService>, balanceService: TokensBalanceService, account: Account, config: Config)
}

protocol TokensNetworkProtocol: TrustNetworkProtocol {
    func tickers(for tokens:[TokenObject], completion: @escaping (_ tickers: [CoinTicker]?) -> Void)
    func ethBalance(completion: @escaping (_ balance: Balance?) -> Void)
    func tokenBalance(for token:TokenObject, completion: @escaping (_ token: Balance?) -> Void)
}

class TokensNetwork: TokensNetworkProtocol {
    /// provider of a `TokensNetwork` to make network requests.
    var provider: MoyaProvider<TrustService>
    /// config of a `TokensNetwork` to have current configuration of the app.
    var config: Config
    /// balanceService of a `TokensNetwork` to obteint tokens balance.
    var balanceService: TokensBalanceService
    /// account of a `TokensNetwork` curent user account reference.
    var account: Account
    /// Construtor.
    ///
    /// - Parameters:
    ///   - provider: to make network requests.
    ///   - balanceService: to obteint tokens balance.
    ///   - account: of the user.
    ///   - config: to configurate network requests.
    required init(provider: MoyaProvider<TrustService>, balanceService: TokensBalanceService, account: Account, config: Config) {
        self.provider = provider
        self.balanceService = balanceService
        self.account = account
        self.config = config
    }
    /// Fetch tickers for tokens.
    ///
    /// - Parameters:
    ///   - tokens: to fetch tickers.
    ///   - completion: to return array of `CoinTicker`.
    func tickers(for tokens:[TokenObject], completion: @escaping (_ tickers: [CoinTicker]?) -> Void){
        let tokensPriceToFetch = TokensPrice(
            currency: config.currency.rawValue,
            tokens: tokens.map { TokenPrice(contract: $0.contract, symbol: $0.symbol) }
        )
        provider.request(.prices(tokensPriceToFetch)) { result in
            guard case .success(let response) = result else {
                completion(nil)
                return
            }
            do {
                let tickers = try response.map([CoinTicker].self, atKeyPath: "response", using: JSONDecoder())
                completion(tickers)
            } catch {
                completion(nil)
            }
        }
    }
    /// Fetch eth token balance.
    ///
    /// - Parameters:
    ///   - completion: to return eth token balance.
    func ethBalance(completion: @escaping (_ balance: Balance?) -> Void) {
        balanceService.getEthBalance(for: account.address) { result in
            switch result {
            case .success(let balance):
                completion(balance)
            case .failure:
                completion(nil)
            }
        }
    }
    /// Fetch ERC token balance.
    ///
    /// - Parameters:
    ///   - token: to fetch balance.
    ///   - completion: to return token balance.
    func tokenBalance(for token:TokenObject, completion: @escaping (_ token: Balance?) -> Void) {
        guard let contract = Address(string: token.contract) else {
            completion(nil)
            return
        }
        balanceService.getBalance(for: account.address, contract: contract) { result in
            switch result {
            case .success(let balance):
                completion(Balance(value: balance))
            case .failure:
                completion(nil)
            }
        }
    }
}
