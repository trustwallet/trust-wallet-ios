// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
@testable import Trust

struct FakeKeystore: Keystore {
    var hasAccounts: Bool {
        return accounts.count > 0
    }
    var accounts: [Account] = []
}

extension FakeKeystore {
    static func make(
        accounts: [Account] = []
    ) -> FakeKeystore {
        return FakeKeystore(
            accounts: accounts
        )
    }
}
