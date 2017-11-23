// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class ExchangeToksnCoordinator {

    var didUpdate: ((ExchangeTokensViewModel) -> Void)?

    var from: ExchangeToken
    var to: ExchangeToken

    let tokens: [ExchangeToken]

    var viewModel: ExchangeTokensViewModel {
        return ExchangeTokensViewModel(
            from: from,
            to: to
        )
    }

    init() {

        defer {
            update()
        }

        self.tokens = [
            ExchangeToken(name: "Ethereum", symbol: "ETH", balance: 1.123),
            ExchangeToken(name: "OmiseGo", symbol: "OMG", balance: 23.22),
        ]

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
}
