// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension WalletSession {
    static func make(
        account: Account = .make()
    ) -> WalletSession {
        return WalletSession(
            account: account
        )
    }
}
