// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ExchangeToken {
    let name: String
    let address: Address
    let symbol: String
    let image: UIImage?
    let balance: Double = 0
    let decimals: Int
}

extension ExchangeToken: Equatable {
    static func == (lhs: ExchangeToken, rhs: ExchangeToken) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
