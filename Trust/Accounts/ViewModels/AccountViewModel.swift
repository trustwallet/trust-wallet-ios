// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

struct AccountViewModel {
    let wallet: Wallet
    let current: Wallet?
    let walletBalance: Balance?
    let server: RPCServer
    init(
        server: RPCServer,
        wallet: Wallet,
        current: Wallet?,
        walletBalance: Balance?
    ) {
        self.server = server
        self.wallet = wallet
        self.current = current
        self.walletBalance = walletBalance
    }
    var isWatch: Bool {
        return wallet.type == .watch(wallet.address)
    }

    var balanceText: String {
        guard let amount = walletBalance?.amountFull else { return "--" }
        return "\(amount) \(server.symbol)"
    }

    var title: String {
        return wallet.address.description
    }

    var isActive: Bool {
        return wallet == current
    }
}
