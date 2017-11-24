// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class ExchangeTokensCoordinator {

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

    init(tokens: [ExchangeToken]) {

        defer {
            update()
        }
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
}
