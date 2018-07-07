// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

extension WalletInfo {
    static func make(
        wallet: Wallet = .make(),
        info: WalletObject = .make()
    ) -> WalletInfo {
        return WalletInfo(wallet: wallet, info: info)
    }
}
