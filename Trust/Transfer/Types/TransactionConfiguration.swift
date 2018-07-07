// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

struct TransactionConfiguration {
    let gasPrice: BigInt
    let gasLimit: BigInt
    let data: Data
    let nonce: BigInt
}
