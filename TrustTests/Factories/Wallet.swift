// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension Wallet {
    static func make(
        type: WalletType = .real(.make())
    ) -> Wallet {
        return Wallet(
            type: type
        )
    }
}
