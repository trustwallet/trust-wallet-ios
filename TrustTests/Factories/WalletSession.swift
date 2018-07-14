// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore
import BigInt

extension WalletSession {
    static func make(
        account: Trust.WalletInfo = .make(),
        config: Config = .make()
    ) -> WalletSession {
        let balance =  BalanceCoordinator(account: account, config: config, storage: FakeTokensDataStore())
        return WalletSession(
            account: account,
            config: config,
            balanceCoordinator: balance,
            nonceProvider: GetNonceProvider.make()
        )
    }
    static func makeWithEthBalance(
        account: Trust.WalletInfo = .make(),
        config: Config = .make(),
        amount: String
        ) -> WalletSession {
        let balance =  BalanceCoordinator(account: account, config: config, storage: FakeTokensDataStore())
        balance.balance = Balance(value:BigInt(amount)!)
        return WalletSession(
            account: account,
            config: config,
            balanceCoordinator: balance,
            nonceProvider: GetNonceProvider.make()
        )
    }
}
