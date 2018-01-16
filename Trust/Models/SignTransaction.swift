// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import TrustKeystore

public struct SignTransaction {
    let value: BigInt
    let account: Account
    let to: Address?
    let nonce: Int
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let chainID: Int
}
