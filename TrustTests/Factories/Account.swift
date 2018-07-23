// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore
import TrustKeystore

extension Account {
    static func make(
        address: EthereumAddress = .make(),
        derivationPath: DerivationPath = Coin.ethereum.derivationPath(at: 0)
    ) -> Account {
        return Account(
            wallet: .none,
            address: address,
            derivationPath: derivationPath
        )
    }
}



