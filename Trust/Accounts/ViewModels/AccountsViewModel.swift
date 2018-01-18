// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct AccountsViewModel {

    let wallets: [Wallet]

    init(wallets: [Wallet]) {
        self.wallets = wallets
    }

    var title: String {
        return NSLocalizedString("wallet.navigation.title", value: "Wallets", comment: "")
    }
}
