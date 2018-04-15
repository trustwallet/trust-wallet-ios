// Copyright SIX DAY LLC. All rights reserved.

import Moya
import TrustCore
import JSONRPCKit
import APIKit
import Result

protocol NetworkProtocol: TrustNetworkProtocol {
    func tickers(with tokenPrices: [TokenPrice], completion: @escaping (_ tickers: [CoinTicker]?) -> Void)
    func tokenBalance(for contract: Address, completion: @escaping (_ result: Balance?) -> Void)
    func assets(completion: @escaping (_ result: ([NonFungibleTokenCategory]?)) -> Void)
    func tokensList(for address: Address, completion: @escaping (_ result: ([TokenObject]?)) -> Void)
    func transactions(for address: Address, startBlock: Int, page: Int, contract: String?, completion: @escaping (_ result: ([Transaction]?, Bool)) -> Void)
    func update(for transaction: Transaction, completion: @escaping (Result<(Transaction, TransactionState), AnyError>) -> Void)
    func search(token: String, completion: @escaping (([TokenObject]) -> Void))
}

class TrustNetwork: NetworkProtocol {
    static let deleteMissingInternalSeconds: Double = 60.0
    static let deleyedTransactionInternalSeconds: Double = 60.0
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

    func tickers(with tokenPrices: [TokenPrice], completion: @escaping (_ tickers: [CoinTicker]?) -> Void) {
        let tokensPriceToFetch = TokensPrice(
            currency: config.currency.rawValue,
            tokens: tokenPrices
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
}
