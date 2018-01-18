// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore

extension WalletSession {
    static func make(
        account: Wallet = .make(),
        config: Config = .make(),
        web3: Web3Swift = Web3Swift()
    ) -> WalletSession {
        let balance =  BalanceCoordinator(account: account, storage: FakeTokensDataStore())
        return WalletSession(
            account: account,
            config: config,
            web3: web3,
            balanceCoordinator: balance
        )
    }
}
