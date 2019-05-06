// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import IPOS
import TrustCore
import BigInt
import RealmSwift

extension WalletSession {
    static func make(
        account: IPOS.WalletInfo = .make(),
        config: Config = .make(),
        realm: Realm = .make(),
        sharedRealm: Realm = .make()
    ) -> WalletSession {
        return WalletSession(
            account: account,
            realm: realm,
            sharedRealm: sharedRealm,
            config: config
        )
    }
//    static func makeWithEthBalance(
//        account: Trust.WalletInfo = .make(),
//        config: Config = .make(),
//        amount: String
//    ) -> WalletSession {
//        let balance =  BalanceCoordinator(storage: FakeTokensDataStore())
//        balance.balance = Balance(value:BigInt(amount)!)
//        return WalletSession(
//            account: account,
//            config: config,
//            nonceProvider: GetNonceProvider.make()
//        )
//    }
}
