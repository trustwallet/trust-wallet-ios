// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import BigInt

extension WalletSession {
    static func make(
        account: Trust.Wallet = .make(),
        config: Config = .make(),
        web3: Web3Swift = Web3Swift()
    ) -> WalletSession {
        let balance =  BalanceCoordinator(account: account, config: config, storage: FakeTokensDataStore())
        return WalletSession(
            account: account,
            config: config,
            web3: web3,
            balanceCoordinator: balance
        )
    }
    static func makeWithEthBalance(
        account: Trust.Wallet = .make(),
        config: Config = .make(),
        web3: Web3Swift = Web3Swift()
        ) -> WalletSession {
        let balance =  BalanceCoordinator(account: account, config: config, storage: FakeTokensDataStore())
        balance.balance = Balance(value:BigInt("11274902618710000000000"))
        return WalletSession(
            account: account,
            config: config,
            web3: web3,
            balanceCoordinator: balance
        )
    }
}
