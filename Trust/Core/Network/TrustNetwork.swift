// Copyright DApps Platform Inc. All rights reserved.

import PromiseKit
import Moya
import TrustCore
import TrustKeystore
import JSONRPCKit
import APIKit
import Result
import BigInt

import enum Result.Result

enum TrustNetworkProtocolError: LocalizedError {
    case missingContractInfo
}

protocol NetworkProtocol: TrustNetworkProtocol {
    func assets(for address: Address) -> Promise<[NonFungibleTokenCategory]>
    func tickers(with tokenPrices: [TokenPrice]) -> Promise<[CoinTicker]>

    func tokensList() -> Promise<[TokenObject]>
    func transactions(for address: Address, on server: RPCServer, startBlock: Int, page: Int, contract: String?, completion: @escaping (_ result: ([Transaction]?, Bool)) -> Void)
    func search(query: String) -> Promise<[TokenObject]>
}

final class TrustNetwork: NetworkProtocol {

    static let deleteMissingInternalSeconds: Double = 60.0
    static let deleyedTransactionInternalSeconds: Double = 60.0
    let provider: MoyaProvider<TrustAPI>
    let wallet: WalletInfo

    private var dict: [String: [String]] {
        return TrustRequestFormatter.toAddresses(from: wallet.accounts)
    }
    private var networks: [Int] {
        return TrustRequestFormatter.networks(from: wallet.accounts)
    }

    init(
        provider: MoyaProvider<TrustAPI>,
        wallet: WalletInfo
    ) {
        self.provider = provider
        self.wallet = wallet
    }

    private func getTickerFrom(rawTicker: CoinTicker, withKey tickersKey: String) -> CoinTicker {
        return CoinTicker(
            price: rawTicker.price,
            percent_change_24h: rawTicker.percent_change_24h,
            contract: EthereumAddress(string: rawTicker.contract) ?? EthereumAddress.zero, // This should not happen
            tickersKey: tickersKey
        )
    }

    func tokensList() -> Promise<[TokenObject]> {
        return Promise { seal in
            provider.request(.getTokens(dict)) { result in
                switch result {
                case .success(let response):
                    do {
                        let items = try response.map(ArrayResponse<TokenObjectList>.self).docs
                        let tokens = items.map { $0.contract }
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

    func assets(for address: Address) -> Promise<[NonFungibleTokenCategory]> {
        return Promise { seal in
            provider.request(.assets(address: address.description)) { result in
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

    func transactions(for address: Address, on server: RPCServer, startBlock: Int, page: Int, contract: String?, completion: @escaping (([Transaction]?, Bool)) -> Void) {
        provider.request(.getTransactions(server: server, address: address.description, startBlock: startBlock, page: page, contract: contract)) { result in
            switch result {
            case .success(let response):
                do {
                    let transactions: [Transaction] = try response.map(ArrayResponse<Transaction>.self).docs
                    let newTransactions = transactions.map { transaction -> Transaction in
                        let newTransaction = transaction
                        newTransaction.coin = server.coin
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

    func search(query: String) -> Promise<[TokenObject]> {
        return Promise { seal in
            provider.request(.search(query: query, networks: networks)) { result in
                switch result {
                case .success(let response):
                    do {
                        let tokens = try response.map(ArrayResponse<TokenObject>.self).docs
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
