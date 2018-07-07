// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

extension Wallet {
    static func make(
        type: WalletType = .privateKey(.make())
    ) -> Wallet {
        return Wallet(
            type: type
        )
    }
}
