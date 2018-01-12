// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit
import BigInt
import TrustKeystore

class ExchangeTokensCoordinator {

    var didUpdate: ((ExchangeTokensViewModel) -> Void)?

    var from: ExchangeToken
    var to: ExchangeToken

    let session: WalletSession
    var tokens: [ExchangeToken]
    let exchangeConfig = ExchangeConfig(server: Config().server)

    private lazy var getBalanceCoordinator: GetBalanceCoordinator = {
        return GetBalanceCoordinator(web3: session.web3)
    }()

    var viewModel: ExchangeTokensViewModel {
        return ExchangeTokensViewModel(
            from: from,
            to: to,
            tokenRate: tokenRate,
            fromValue: fromValue,
            toValue: toValue,
            balance: balance
        )
    }

    var tokenRate: ExchangeTokenRate? {
        didSet {
            update()
        }
    }
    var balance: BalanceProtocol? {
        didSet {
            update()
        }
    }
    var fromValue: Double? = 0
    var toValue: Double? = 0

    init(
        session: WalletSession,
        tokens: [ExchangeToken]
    ) {

        defer {
            update()
            getPrice()
            getBalance()
        }
        self.session = session
        self.tokens = tokens
        self.from = self.tokens.first!
        self.to = self.tokens.last!
    }

    func fetch() {
        getBalance()
        getBalances()
    }

    func update() {
        didUpdate?(viewModel)
    }

    func swap() {
        Swift.swap(&from, &to)
        update()
    }

    func changeToken(direction: SelectTokenDirection, token: ExchangeToken) {
        switch direction {
        case .from:
            if token == to || (to.address != exchangeConfig.tokenAddress && token.address != exchangeConfig.tokenAddress) {
                to = from
            }
            from = token
        case .to:
            if token == from || (from.address != exchangeConfig.tokenAddress && token.address != exchangeConfig.tokenAddress) {
                from = to
            }
            to = token
        }

        balance = nil
        tokenRate = nil

        update()
        getPrice()
        getBalance()
        getBalances()
    }

    func getPrice() {
        let request = ExchangeGetPrice(from: from, to: to)
        session.web3.request(request: request) { result in
            switch result {
            case .success(let res):
                let request2 = EtherServiceRequest(batch: BatchFactory().create(CallRequest(to: self.exchangeConfig.contract?.description ?? "", data: res)))
                Session.send(request2) { [weak self] result2 in
                    switch result2 {
                    case .success(let balance):
                        let request = ExchangeGetPriceDecode(data: balance)
                        self?.session.web3.request(request: request) { result in
                            switch result {
                            case .success(let res):
                                self?.tokenRate = ExchangeTokenRate(rate: res)
                            case .failure(let error):
                                NSLog("getPrice3 error \(error)")
                            }
                        }
                    case .failure(let error):
                        NSLog("getPrice2 error \(error)")
                    }
                }
            case .failure(let error):
                NSLog("getPrice error \(error)")
            }
        }
    }

    func getBalances() {
        let onlyTokens = tokens.filter { $0.address != exchangeConfig.tokenAddress }
        onlyTokens.forEach { [weak self] token in
            self?.getBalanceCoordinator.getBalance(for: session.account.address, contract: token.address) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    if let index = self.tokens.index(of: token) {
                        let oldToken = self.tokens[index]
                        let newToken = ExchangeToken(
                            name: oldToken.name,
                            address: oldToken.address,
                            symbol: oldToken.symbol,
                            image: oldToken.image,
                            balance: balance,
                            decimals: oldToken.decimals
                        )
                        self.tokens[index] = newToken
                    }
                case .failure:
                    //TODO
                    break
                }
            }
        }

        let etherTokens = tokens.filter { $0.address == exchangeConfig.tokenAddress }
        guard let etherToken = etherTokens.first else { return }
        getETHBalance(address: session.account.address) { [weak self] balance in
            guard let `self` = self else { return }
            if let index = self.tokens.index(of: etherToken) {
                let newToken = ExchangeToken(
                    name: etherToken.name,
                    address: etherToken.address,
                    symbol: etherToken.symbol,
                    image: etherToken.image,
                    balance: balance.value,
                    decimals: etherToken.decimals
                )
                self.tokens[index] = newToken
            }
        }
    }

    func getETHBalance(address: Address, completion: ((BalanceProtocol) -> Void)? = .none) {
        let request = EtherServiceRequest(batch: BatchFactory().create(BalanceRequest(address: address.address)))
        Session.send(request) { result in
            switch result {
            case .success(let balance):
                completion?(balance)
            case .failure: break
            }
        }
    }

    func getBalance() {
        if from.address == exchangeConfig.tokenAddress {
            self.getETHBalance(address: session.account.address) { [weak self] balance in
                self?.balance = balance
            }
        } else {
            // get price for token
            getBalanceCoordinator.getBalance(for: session.account.address, contract: from.address) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    self.balance = TokenBalance(token: self.from, value: balance)
                case .failure:
                    //TODO
                    break
                }
            }
        }
    }
}
