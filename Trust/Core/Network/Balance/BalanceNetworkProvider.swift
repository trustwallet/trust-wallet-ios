// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import PromiseKit
import BigInt

protocol BalanceNetworkProvider {
    var addressUpdate: Address { get }
    func balance() -> Promise<BigInt>
}
