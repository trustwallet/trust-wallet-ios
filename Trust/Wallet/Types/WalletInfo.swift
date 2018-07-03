// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct WalletInfo {
    let wallet: Wallet
    let info: WalletObject

    init(
        wallet: Wallet,
        info: WalletObject? = .none
    ) {
        self.wallet = wallet
        self.info = info ?? WalletObject.from(wallet)
    }
}
