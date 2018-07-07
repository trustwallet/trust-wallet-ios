// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

protocol BalanceProtocol {
    var value: BigInt { get }
    var amountShort: String { get }
    var amountFull: String { get }
}
