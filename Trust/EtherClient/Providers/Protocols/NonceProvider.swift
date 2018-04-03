// Copyright SIX DAY LLC. All rights reserved.

import Foundation

protocol NonceProvider {
    var remoteNonce: Int? { get }
    var latestNonce: Int? { get }
    var nextNonce: Int? { get }
    func getNonce(for transaction: UnconfirmedTransaction) -> Int
    func fetch()
    func fetchIfNeeded()
}
