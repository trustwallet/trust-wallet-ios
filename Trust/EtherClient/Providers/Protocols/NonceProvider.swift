// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

protocol NonceProvider {
    var remoteNonce: BigInt? { get }
    var latestNonce: BigInt? { get }
    var nextNonce: BigInt? { get }
    func fetch()
    func fetchIfNeeded()
}
