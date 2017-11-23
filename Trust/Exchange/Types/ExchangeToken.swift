// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeToken {
    let name: String
    let symbol: String
    let balance: Double
}

extension ExchangeToken: Equatable {
    static func == (lhs: ExchangeToken, rhs: ExchangeToken) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
