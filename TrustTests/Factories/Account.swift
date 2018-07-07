// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore
import TrustKeystore

extension Account {
    static func make(
        address: Address = .make(),
        type: AccountType = .encryptedKey,
        url: URL = URL(fileURLWithPath: "")
    ) -> Account {
        return Account(address: address, type: type, url: url)
    }
}



