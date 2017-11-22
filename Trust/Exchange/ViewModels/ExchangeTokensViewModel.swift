// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeToken {
    let name: String
    let symbol: String
    let balance: Double
}

struct ExchangeTokensViewModel {

    let from: ExchangeToken
    let to: ExchangeToken

    init(
        from: ExchangeToken,
        to: ExchangeToken
    ) {
        self.from = from
        self.to = to
    }

    var fromSymbol: String {
        return from.symbol
    }

    var toSymbol: String {
        return to.symbol
    }
}
