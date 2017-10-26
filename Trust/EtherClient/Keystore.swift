// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result

protocol Keystore {
    var hasAccounts: Bool { get }
    var accounts: [Account] { get }
    var recentlyUsedAccount: Account? { get set }

    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void)
}
