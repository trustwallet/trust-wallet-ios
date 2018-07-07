// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import TrustCore
import TrustKeystore

public struct SignTransaction {
    let value: BigInt
    let account: Account
    let to: Address?
    let nonce: BigInt
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let chainID: Int

    // additinalData
    let localizedObject: LocalizedOperationObject?
}
