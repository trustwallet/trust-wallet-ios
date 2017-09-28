// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct TransactionConfiguration {
    let speed: TransactionSpeed

    init(speed: TransactionSpeed = .regular) {
        self.speed = speed
    }
}
