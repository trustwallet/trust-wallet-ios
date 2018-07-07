// Copyright DApps Platform Inc. All rights reserved.

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

extension WalletInfo: Equatable {
    static func == (lhs: WalletInfo, rhs: WalletInfo) -> Bool {
        return lhs.wallet.description == rhs.wallet.description
    }
}
