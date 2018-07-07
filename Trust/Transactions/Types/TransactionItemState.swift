// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum TransactionState: Int {
    case completed
    case pending
    case error
    case failed
    case unknown
    case deleted

    init(int: Int) {
        self = TransactionState(rawValue: int) ?? .unknown
    }
}
