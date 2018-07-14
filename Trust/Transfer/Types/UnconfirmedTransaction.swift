// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import TrustCore

struct UnconfirmedTransaction {
    let transferType: TransferType
    let value: BigInt
    let to: EthereumAddress?
    let data: Data?

    let gasLimit: BigInt?
    let gasPrice: BigInt?
    let nonce: BigInt?
}
