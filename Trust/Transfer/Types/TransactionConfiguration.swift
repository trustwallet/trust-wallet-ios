// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct TransactionConfiguration {
    let gasPrice: BigInt
    let gasLimit: BigInt
    let data: Data
}
