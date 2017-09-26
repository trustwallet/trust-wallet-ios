// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

struct Account {
    let address: Address

    init(address: Address) {
        self.address = address
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address.address == rhs.address.address
    }
}
