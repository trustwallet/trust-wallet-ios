// Copyright DApps Platform Inc. All rights reserved.

import PromiseKit
import Moya
import TrustCore
import JSONRPCKit
import APIKit
import Result
import BigInt

import enum Result.Result

enum TrustNetworkProtocolError: LocalizedError {
    case missingContractInfo
}

protocol NetworkProtocol: TrustNetworkProtocol {
    func assets() -> Promise<[NonFungibleTokenCategory]>
    func tickers(with tokenPrices: [TokenPrice]) -> Promise<[CoinTicker]>
    func tokensList(for address: Address) -> Promise<[TokenObject]>
    func transactions(for address: Address, startBlock: Int, page: Int, contract: String?, completion: @escaping (_ result: ([Transaction]?, Bool)) -> Void)
    func search(token: String) -> Promise<[TokenObject]>
}



final class TrustNetwork: NetworkProtocol {

    static let deleteMissingInternalSeconds: Double = 60.0
    static let deleyedTransactionInternalSeconds: Double = 60.0
    let provider: MoyaProvider<TrustAPI>
    let balanceService: TokensBalanceService
    let address: Address
    let server: RPCServer

    required init(
        provider: MoyaProvider<TrustAPI>,
        balanceService: TokensBalanceService,
        address: Address,
        server: RPCServer
    ) {
        self.provider = provider
        self.balanceService = balanceService
        self.address = address
        self.server = server
    }

    func tickers(with tokenPrices: [TokenPrice], completion: @escaping (_ tickers: [CoinTicker]?) -> Void) {
        let tokensPriceToFetch = TokensPrice(
            currency: Config.current.currency.rawValue,
            tokens: tokenPrices
        )
        provider.request(.prices(tokensPriceToFetch)) { result in
            guard case .success(let response) = result else {
                completion(nil)
                return
            }
            do {
                let rawTickers = try response.map([CoinTicker].self, atKeyPath: "response", using: JSONDecoder())
                let tickers = rawTickers.map {rawTicker in
                    return self.getTickerFrom(rawTicker: rawTicker, withKey: CoinTickerKeyMaker.makeCurrencyKey())
                }
                completion(tickers)
            } catch {
                completion(nil)
            }
        }
    }

    private func getTickerFrom(rawTicker: CoinTicker, withKey tickersKey: String) -> CoinTicker {
        return CoinTicker(
            symbol: rawTicker.symbol,
            price: rawTicker.price,
            percent_change_24h: rawTicker.percent_change_24h,
            contract: EthereumAddress(string: rawTicker.contract) ?? EthereumAddress.zero, // This should not happen
            tickersKey: tickersKey
        )
    }

    func tokensList(for address: Address) -> Promise<[TokenObject]> {
        return Promise { seal in
            provider.request(.getTokens(server: server, address: address.description)) { result in
                switch result {
                case .success(let response):
                    do {
                        let items = try response.map(ArrayResponse<TokenObjectList>.self).docs
                        let tokens = items.map { $0.contract }
                        let newTokens = tokens.map { token -> TokenObject in
                            let newToken = token
                            newToken.chainID = self.server.chainID
                            return newToken
                        }

                        seal.fulfill(newTokens)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    func tickers(with tokenPrices: [TokenPrice]) -> Promise<[CoinTicker]> {
        return Promise { seal in
            let tokensPriceToFetch = TokensPrice(
                currency: Config.current.currency.rawValue,
                tokens: tokenPrices
            )
            provider.request(.prices(tokensPriceToFetch)) { result in
                switch result {
                case .success(let response):
                    do {
                        let rawTickers = try response.map([CoinTicker].self, atKeyPath: "response", using: JSONDecoder())
                        let tickers = rawTickers.map { rawTicker in
                            return self.getTickerFrom(rawTicker: rawTicker, withKey: CoinTickerKeyMaker.makeCurrencyKey())
                        }
                        seal.fulfill(tickers)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    func assets() -> Promise<[NonFungibleTokenCategory]> {
        return Promise { seal in
            provider.request(.assets(server: server, address: address.description)) { result in
                switch result {
                case .success(let response):
                    do {
                        let tokens = try response.map(ArrayResponse<NonFungibleTokenCategory>.self).docs
                        seal.fulfill(tokens)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    func transactions(for address: Address, startBlock: Int, page: Int, contract: String?, completion: @escaping (([Transaction]?, Bool)) -> Void) {
        provider.request(.getTransactions(server: server, address: address.description, startBlock: startBlock, page: page, contract: contract)) { result in
            switch result {
            case .success(let response):
                do {
                    let transactions: [Transaction] = try response.map(ArrayResponse<Transaction>.self).docs
                    let newTransactions = transactions.map { transaction -> Transaction in
                        let newTransaction = transaction
                        newTransaction.chainID = self.server.chainID
                        return newTransaction
                    }
                    completion((newTransactions, true))
                } catch {
                    completion((nil, false))
                }
            case .failure:
                completion((nil, false))
            }
        }
    }

    func search(token: String) -> Promise<[TokenObject]> {
        return Promise { seal in
            provider.request(.search(server: server, token: token)) { result in
                switch result {
                case .success(let response):
                    do {
                        let tokens = try response.map([TokenObject].self)
                        seal.fulfill(tokens)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
