// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
@testable import Trust

extension Account {
    static func make(
        address: Address = .make()
    ) -> Account {
        return Account(
            address: address
        )
    }
}



