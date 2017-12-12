// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct AccountsViewModel {

    let accounts: [Account]

    init(accounts: [Account]) {
        self.accounts = accounts
    }

    var title: String {
        return NSLocalizedString("wallet.navigation.title", value: "Wallets", comment: "")
    }
}
