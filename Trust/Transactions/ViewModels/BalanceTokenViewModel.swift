// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct BalanceTokenViewModel: BalanceBaseViewModel {

    let token: Token

    var currencyAmount: String? {
        return nil
    }

    var amountFull: String {
        return token.amount
    }

    var amountShort: String {
        return token.amount
    }

    var symbol: String {
        return token.symbol
    }
}
