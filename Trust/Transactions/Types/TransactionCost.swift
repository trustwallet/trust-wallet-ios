// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import Geth

enum TransactionSpeed {
    case regular
    case custom(gasPrice: BigInt, gasLimit: BigInt)

    var gasPrice: BigInt {
        switch self {
        case .regular:
            return 30_000_000_000
        case .custom(let gasPrice, _):
            return gasPrice
        }
    }

    var gasLimit: BigInt {
        switch self {
        case .regular:
            return 90_000
        case .custom(_, let gasLimit):
            return gasLimit
        }
    }
}
