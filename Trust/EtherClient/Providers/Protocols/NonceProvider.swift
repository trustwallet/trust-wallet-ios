// Copyright SIX DAY LLC. All rights reserved.

import Foundation

protocol NonceProvider {
    var latestNonce: Int? { get }
    var nextNonce: Int? { get }
    func getNonce(for transaction: UnconfirmedTransaction) -> Int
}
