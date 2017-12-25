// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth
import BigInt

public struct SignTransaction {
    let value: BigInt
    let account: Account
    let address: Address
    let nonce: Int
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let chainID: Int
}
