// Copyright DApps Platform Inc. All rights reserved.

import UIKit

import TrustCore
import BigInt

final class WalletValueOperation: TrustOperation {
    private var balanceProvider: WalletBalanceProvider
    private let keystore: Keystore
    private let wallet: WalletObject

    init(
        balanceProvider: WalletBalanceProvider,
        keystore: Keystore,
        wallet: WalletObject
        ) {
        self.balanceProvider = balanceProvider
        self.keystore = keystore
        self.wallet = wallet
    }

    override func main() {
        _ = balanceProvider.balance().done { [weak self] balance in
            guard let strongSelf = self else {
                self?.finish()
                return
            }
            strongSelf.updateModel(with: balance)
        }
    }

    private func updateModel(with balance: BigInt) {
        self.keystore.store(object: wallet, fields: [.balance(balance.description)])
        self.finish()
    }
}
