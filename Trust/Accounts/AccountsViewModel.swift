// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation

struct AccountsViewModel {
    
    let accounts: [Account]
    
    init(accounts: [Account]) {
        self.accounts = accounts
    }
    
    var title: String {
        return "Accounts (\(accounts.count))"
    }
}
