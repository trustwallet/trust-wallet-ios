// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

struct AccountViewModel {
    let wallet: Wallet
    let current: Wallet?
    let walletBalance: Balance?
    init(wallet: Wallet, current: Wallet?, walletBalance: Balance?) {
        self.wallet = wallet
        self.current = current
        self.walletBalance = walletBalance
    }
    var isWatch: Bool {
        return wallet.type == .watch(wallet.address)
    }
    var balance: String {
        return walletBalance?.amountFull ?? "0"
    }
    var title: String {
        return wallet.address.description
    }
    var isActive: Bool {
        return wallet == current
    }
}
