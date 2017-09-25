// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
@testable import Trust

struct FakeKeystore: Keystore {
    var hasAccounts: Bool {
        return accounts.count > 0
    }
    var accounts: [Account]
    var recentlyUsedAccount: Account?

    init(
        accounts: [Account] = [],
        recentlyUsedAccount: Account? = .none
    ) {
        self.accounts = accounts
        self.recentlyUsedAccount = recentlyUsedAccount
    }
}

extension FakeKeystore {
    static func make(
        accounts: [Account] = [],
        recentlyUsedAccount: Account? = .none
    ) -> FakeKeystore {
        return FakeKeystore(
            accounts: accounts,
            recentlyUsedAccount: recentlyUsedAccount
        )
    }
}
