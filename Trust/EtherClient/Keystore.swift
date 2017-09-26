// Copyright SIX DAY LLC. All rights reserved.

import Foundation

protocol Keystore {
    var hasAccounts: Bool { get }
    var accounts: [Account] { get }
    var recentlyUsedAccount: Account? { get set }
}
