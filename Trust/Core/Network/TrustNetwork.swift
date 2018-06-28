// Copyright SIX DAY LLC. All rights reserved.

import PromiseKit
import Moya
import TrustCore
import JSONRPCKit
import APIKit
import Result
import enum Result.Result

enum TrustNetworkProtocolError: LocalizedError {
    case missingPrices
    case missingContractInfo
}

protocol NetworkProtocol: TrustNetworkProtocol {
    func tokenBalance(for contract: Address, completion: @escaping (_ result: Balance?) -> Void)
    func assets() -> Promise<[NonFungibleTokenCategory]>
    func tickers(with tokenPrices: [TokenPrice]) -> Promise<[CoinTicker]>
    func ethBalance() -> Promise<Balance>
    func tokensList(for address: Address) -> Promise<[TokenObject]>
    func transactions(for address: Address, startBlock: Int, page: Int, contract: String?, completion: @escaping (_ result: ([Transaction]?, Bool)) -> Void)
    func update(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void)
    func search(token: String, completion: @escaping (([TokenObject]) -> Void))
    func search(token: String) -> Promise<TokenObject>
}

class TrustNetwork: NetworkProtocol {
    static let deleteMissingInternalSeconds: Double = 60.0
    static let deleyedTransactionInternalSeconds: Double = 60.0
    let provider: MoyaProvider<TrustService>
    let APIProvider: MoyaProvider<TrustAPI>
    let config: Config
    let balanceService: TokensBalanceService
    let account: Wallet

    required init(
        provider: MoyaProvider<TrustService>,
        APIProvider: MoyaProvider<TrustAPI>,
        balanceService: TokensBalanceService,
        account: Wallet,
        config: Config
    ) {
        self.provider = provider
        self.APIProvider = APIProvider
        self.balanceService = balanceService
        self.account = account
        self.config = config
    }

    func tickers(with tokenPrices: [TokenPrice], completion: @escaping (_ tickers: [CoinTicker]?) -> Void) {
        let tokensPriceToFetch = TokensPrice(
            currency: config.currency.rawValue,
            tokens: tokenPrices
        )
        APIProvider.request(.prices(tokensPriceToFetch)) { result in
            guard case .success(let response) = result else {
                completion(nil)
                return
            }
            do {
                let rawTickers = try response.map([CoinTicker].self, atKeyPath: "response", using: JSONDecoder())
                let tickers = rawTickers.map {rawTicker in
                    return self.getTickerFrom(rawTicker: rawTicker, withKey: CoinTickerKeyMaker.makeCurrencyKey(for: self.config))
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
            contract: Address(string: rawTicker.contract) ?? Address.zero, // This should not happen
            tickersKey: tickersKey
        )
    }

    func tokenBalance(for contract: Address, completion: @escaping (_ result: Balance?) -> Void) {
        if contract == TokensDataStore.etherToken(for: config).address {
            balanceService.getEthBalance(for: account.address) { result in
                switch result {
                case .success(let balance):
                    completion(balance)
                case .failure:
                    completion(nil)
                }
            }
        } else {
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

    func ethBalance() -> Promise<Balance> {
        return Promise { seal in
            balanceService.getEthBalance(for: account.address) { result in
                switch result {
                case .success(let balance):
                    seal.fulfill(balance)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    func tokensList(for address: Address) -> Promise<[TokenObject]> {
        return Promise { seal in
            provider.request(.getTokens(address: address.description, showBalance: false)) { result in
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
                currency: config.currency.rawValue,
                tokens: tokenPrices
            )
            APIProvider.request(.prices(tokensPriceToFetch)) { result in
                guard case .success(let response) = result else {
                    seal.reject(TrustNetworkProtocolError.missingPrices)
                    return
                }
                do {
                    let rawTickers = try response.map([CoinTicker].self, atKeyPath: "response", using: JSONDecoder())
                    let tickers = rawTickers.map {rawTicker in
                        return self.getTickerFrom(rawTicker: rawTicker, withKey: CoinTickerKeyMaker.makeCurrencyKey(for: self.config))
                    }
                    seal.fulfill(tickers)
                } catch {
                   seal.reject(error)
                }
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

    func assets() -> Promise<[NonFungibleTokenCategory]> {
        return Promise { seal in
            provider.request(.assets(address: account.address.description)) { result in
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
        provider.request(.getTransactions(address: address.description, startBlock: startBlock, page: page, contract: contract)) { result in
            switch result {
            case .success(let response):
                do {
                    let transactions: [Transaction] = try response.map(ArrayResponse<Transaction>.self).docs
                    completion((transactions, true))
                } catch {
                    completion((nil, false))
                }
            case .failure:
                completion((nil, false))
            }
        }
    }

    func update(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void) {
        let request = GetTransactionRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(batch: BatchFactory().create(request))) { [weak self] result in
            switch result {
            case .success(let tx):
                guard let newTransaction = Transaction.from(transaction: tx) else {
                    return completion(.success((transaction, .pending)))
                }
                if newTransaction.blockNumber > 0 {
                    self?.getReceipt(for: newTransaction, completion: completion)
                }
            case .failure(let error):
                switch error {
                case .responseError(let error):
                    guard let error = error as? JSONRPCError else { return }
                    switch error {
                    case .responseError:
                        if transaction.date > Date().addingTimeInterval(TrustNetwork.deleteMissingInternalSeconds) {
                            completion(.success((transaction, .deleted)))
                        }
                    case .resultObjectParseError:
                        if transaction.date > Date().addingTimeInterval(TrustNetwork.deleteMissingInternalSeconds) {
                            completion(.success((transaction, .failed)))
                        }
                    default: break
                    }
                default: break
                }
            }
        }
    }

    private func getReceipt(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void) {
        let request = GetTransactionReceiptRequest(hash: transaction.id)
        Session.send(EtherServiceRequest(batch: BatchFactory().create(request))) { result in
            switch result {
            case .success(let receipt):
                let newTransaction = transaction
                newTransaction.gasUsed = receipt.gasUsed
                let state: TransactionState = receipt.status ? .completed : .failed
                completion(.success((newTransaction, state)))
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    func search(token: String, completion: @escaping (([TokenObject]) -> Void)) {
        guard !token.isEmpty else {
            return completion([])
        }
        provider.request(.search(token: token)) { result in
            switch result {
            case .success(let response):
                do {
                    let tokens = try response.map([TokenObject].self)
                    completion(tokens)
                } catch {
                    completion([])
                }
            case .failure: completion([])
            }
        }
    }

    func search(token: String) -> Promise<TokenObject> {
        return Promise { seal in
            provider.request(.search(token: token)) { result in
                switch result {
                case .success(let response):
                    do {
                        let tokens = try response.map([TokenObject].self)
                        guard let token = tokens.first(where: { $0.address == Address(string: token) }) else {
                             return seal.reject(TrustNetworkProtocolError.missingContractInfo)
                        }
                        seal.fulfill(token)
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
