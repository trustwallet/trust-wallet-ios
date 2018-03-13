// Copyright SIX DAY LLC. All rights reserved.

import Moya
import TrustKeystore

protocol TokensNetworkProtocol: TrustNetworkProtocol {
    func tickers(for tokens: [TokenObject], completion: @escaping (_ tickers: [CoinTicker]?) -> Void)
    func ethBalance(completion: @escaping (_ balance: Balance?) -> Void)
    func tokenBalance(for token: TokenObject, completion: @escaping (_ result: (TokenObject, Balance?)) -> Void)
    func assets(completion: @escaping (_ result: ([NonFungibleTokenCategory]?)) -> Void)
    func tokensList(for address: Address, completion: @escaping (_ result: ([TokenObject]?)) -> Void)
}

class TokensNetwork: TokensNetworkProtocol {
    let provider: MoyaProvider<TrustService>

    let config: Config

    let balanceService: TokensBalanceService

    let account: Wallet

    required init(provider: MoyaProvider<TrustService>, balanceService: TokensBalanceService, account: Wallet, config: Config) {
        self.provider = provider
        self.balanceService = balanceService
        self.account = account
        self.config = config
    }

    func tickers(for tokens: [TokenObject], completion: @escaping (_ tickers: [CoinTicker]?) -> Void) {
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

    func tokenBalance(for token: TokenObject, completion: @escaping (_ result: (TokenObject, Balance?)) -> Void) {
        balanceService.getBalance(for: account.address, contract: token.address) { result in
            switch result {
            case .success(let balance):
                completion((token, Balance(value: balance)))
            case .failure:
                completion((token, nil))
            }
        }
    }

    func tokensList(for address: Address, completion: @escaping (([TokenObject]?)) -> Void) {
        provider.request(.getTokens(address: address.description, showBalance: false)) { result in
            switch result {
            case .success(let response):
                do {
                    let items = try response.map(ArrayResponse<TokenObjectList>.self).docs
                    let tokens = items.map { $0.contract }
                    completion(tokens)
                } catch {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }

    func assets(completion: @escaping (_ result: ([NonFungibleTokenCategory]?)) -> Void) {
        provider.request(.assets(address: account.address.description)) { result in
            switch result {
            case .success(let response):
                do {
                    let tokens = try response.map(ArrayResponse<NonFungibleTokenCategory>.self).docs
                    completion(tokens)
                } catch {
                    completion(nil)
                }
            case .failure:
                    completion(nil)
            }
        }
    }
}
