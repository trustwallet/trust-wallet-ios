// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import TrustCore


extension Wallet {
    static func k() -> KeystoreKey {
        var key = try! KeystoreKey(password: "hello", for: .ethereum)
        key.activeAccounts.append(.make())
        return key
    }

    static func make(
        keyURL: URL = URL(fileURLWithPath: ""),
        key: KeystoreKey = Wallet.k()
    ) -> Wallet {
        let wallet = Wallet(
            keyURL: URL(fileURLWithPath: ""),
            key: key
        )
        let _ = try! wallet.getAccount(password: "hello")
        return wallet
    }
}

extension Account {
    static func make(wallet: Wallet) -> Account {
        return Account(
            wallet: .make(),
            address: EthereumAddress.make(),
            derivationPath: Coin.ethereum.derivationPath(at: 0)
        )
    }
}
