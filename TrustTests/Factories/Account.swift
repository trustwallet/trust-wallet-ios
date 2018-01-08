// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore

extension Account {
    static func make(
        address: Address = .make()
    ) -> Account {
        return Account(
            address: address
        )
    }
}



