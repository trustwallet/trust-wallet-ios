// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth

enum AccountType {
    case real
    case watch
}

struct Account {
    let address: Address
    let type: AccountType

    init(address: Address, type: AccountType = .real) {
        self.address = address
        self.type = type
    }
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address.address == rhs.address.address
    }
}
