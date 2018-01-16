// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import TrustKeystore

struct UnconfirmedTransaction {
    let transferType: TransferType
    let value: BigInt
    let to: Address?
    let data: Data?
}
