// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct TokenBalance: BalanceProtocol {

    let token: ExchangeToken
    let value: BigInt

    init(token: ExchangeToken, value: BigInt) {
        self.token = token
        self.value = value
    }

    var amountShort: String {
        // TODO Implement short amount
        return amountFull
    }

    var amountFull: String {
        return TokensFormatter.from(token: token, amount: value.description) ?? ""
    }
}
