// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

enum TransactionCost {
    case fast
    case cheap
    case custom(gasPrice: GethBigInt, gasLimit: GethBigInt)

    var gasPrice: GethBigInt {
        switch self {
        case .fast: return GethNewBigInt(40000000000)
        case .cheap: return GethNewBigInt(15000000000)
        case .custom(let gasPrice, _): return gasPrice
        }
    }

    var gasLimit: GethBigInt {
        switch self {
        case .cheap, .fast: return GethNewBigInt(90000)
        case .custom(_, let gasLimit): return gasLimit
        }
    }
}
