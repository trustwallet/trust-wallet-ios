// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TransactionState: Int {
    case completed
    case pending
    case error
    case unknown

    init(int: Int) {
        self = TransactionState(rawValue: int) ?? .unknown
    }
}
