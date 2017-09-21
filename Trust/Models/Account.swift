// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import Geth

struct Account {
    var address: String {
        return gethAccount.getAddress().getHex() ?? ""
    }
    
    let gethAccount: GethAccount
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.address == rhs.address
    }
}
