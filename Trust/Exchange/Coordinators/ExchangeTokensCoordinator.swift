// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class ExchangeTokensCoordinator {

    var didUpdate: ((ExchangeTokensViewModel) -> Void)?

    var from: ExchangeToken
    var to: ExchangeToken

    let session: WalletSession
    let tokens: [ExchangeToken]

    var viewModel: ExchangeTokensViewModel {
        return ExchangeTokensViewModel(
            from: from,
            to: to
        )
    }

    init(
        session: WalletSession,
        tokens: [ExchangeToken]
    ) {

        defer {
            update()
            getPrice()
        }
        self.session = session
        self.tokens = tokens
        self.from = self.tokens.first!
        self.to = self.tokens.last!
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
            if token == to { to = from }
            from = token
        case .to:
            if token == from { from = to }
            to = token
        }
        update()
    }

    func getPrice() {
        let request = ExchangeGetPrice(from: from.address, to: to.address)

        session.web3.request(request: request) { result in
            switch result {
            case .success(let res):
                NSLog("getPrice result \(res)")

            case .failure(let error):
                NSLog("getPrice error \(error)")
                //completion(.failure(AnyError(error)))
            }
        }
    }

    func getBalance() {
        let request = ExchangeGetPrice(from: from.address, to: to.address)

        session.web3.request(request: request) { result in
            switch result {
            case .success(let res):
                NSLog("getPrice result \(res)")

            case .failure(let error):
                NSLog("getPrice error \(error)")
                //completion(.failure(AnyError(error)))
            }
        }
    }
}
