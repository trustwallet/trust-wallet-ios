// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum CoinTickerID {
    case ETH
    case custom(String)

    var ID: String {
        switch self {
        case .ETH: return "ethereum"
        case .custom(let ID): return ID
        }
    }
}
