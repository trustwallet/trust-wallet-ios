// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

public struct SignTransaction {
    let amount: GethBigInt
    let account: Account
    let address: Address
    let nonce: Int
    let speed: TransactionSpeed
    let data: Data
    let chainID: GethBigInt
}
