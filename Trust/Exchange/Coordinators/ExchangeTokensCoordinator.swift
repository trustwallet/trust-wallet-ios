// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import APIKit

class ExchangeTokensCoordinator {

    var didUpdate: ((ExchangeTokensViewModel) -> Void)?

    var from: ExchangeToken
    var to: ExchangeToken

    let session: WalletSession
    let tokens: [ExchangeToken]
    let exchangeConfig = ExchangeConfig(server: Config().server)

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
    var balance: Balance? {
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
    }

    func getPrice() {
        let request = ExchangeGetPrice(from: from, to: to)
        session.web3.request(request: request) { result in
            switch result {
            case .success(let res):
                let request2 = EtherServiceRequest(batch: BatchFactory().create(CallRequest(to: self.exchangeConfig.contract.address, data: res)))
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

    func getBalance() {
        if from.address == exchangeConfig.tokenAddress {
            // get balance for ethereum
            let request = EtherServiceRequest(batch: BatchFactory().create(BalanceRequest(address: session.account.address.address)))
            Session.send(request) { [weak self] result in
                switch result {
                case .success(let balance):
                    self?.balance = balance
                    NSLog("balance \(balance)")
                case .failure: break
                }
            }
        } else {
            // get price for token
        }
    }
}
