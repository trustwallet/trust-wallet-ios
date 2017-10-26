// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import Result

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

    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        completion(.success(.make()))
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
