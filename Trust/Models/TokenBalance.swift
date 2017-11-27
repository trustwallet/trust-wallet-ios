// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct TokenBalance: BalanceProtocol {

    let token: ExchangeToken
    let data: String

    init(token: ExchangeToken, data: String) {
        self.token = token
        self.data = data
    }

    var amount: String {
        return TokensFormatter.from(token: token, amount: data) ?? ""
    }

    var amountFull: String {
        // TODO Implement full amount
        return amount
    }
}
