// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

extension WalletInfo {
    static func make(
        type: WalletType = WalletType.privateKey(.make()),
        info: WalletObject = WalletObject()
    ) -> WalletInfo {
        return WalletInfo(
            type: type,
            info: info
        )
    }
}
