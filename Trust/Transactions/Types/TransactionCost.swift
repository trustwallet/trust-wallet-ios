// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

enum TransactionSpeed {
    case fast
    case regular
    case cheap
    case custom(gasPrice: GethBigInt, gasLimit: GethBigInt)

    var gasPrice: GethBigInt {
        switch self {
        case .fast: return GethNewBigInt(6000000000)
        case .regular: return GethNewBigInt(3000000000)
        case .cheap: return GethNewBigInt(1000000000)
        case .custom(let gasPrice, _): return gasPrice
        }
    }

    var gasLimit: GethBigInt {
        switch self {
        case .regular, .fast, .cheap: return GethNewBigInt(21000)
        case .custom(_, let gasLimit): return gasLimit
        }
    }
}
