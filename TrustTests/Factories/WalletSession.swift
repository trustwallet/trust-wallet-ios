// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

extension WalletSession {
    static func make(
        account: Account = .make(),
        config: Config = .make()
    ) -> WalletSession {
        return WalletSession(
            account: account,
            config: config
        )
    }
}
