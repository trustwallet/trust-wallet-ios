// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore

struct WalletInfo {
    let wallet: Wallet
    let info: WalletObject

    var address: Address {
        return wallet.address
    }

    init(
        wallet: Wallet,
        info: WalletObject? = .none
    ) {
        self.wallet = wallet
        self.info = info ?? WalletObject.from(wallet)
    }
}
