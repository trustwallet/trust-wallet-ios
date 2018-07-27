// Copyright DApps Platform Inc. All rights reserved.

import UIKit

import TrustCore
import BigInt

final class WalletValueOperation: TrustOperation {
    private var balanceProvider: BalanceNetworkProvider
    private let keystore: Keystore
    private let wallet: WalletObject

    init(
        balanceProvider: BalanceNetworkProvider,
        keystore: Keystore,
        wallet: WalletObject
        ) {
        self.balanceProvider = balanceProvider
        self.keystore = keystore
        self.wallet = wallet
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        updateValue()
    }

    private func updateValue() {
        executing(true)
        _ = balanceProvider.balance().done { [weak self] balance in
            guard let strongSelf = self else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            strongSelf.updateModel(with: balance)
        }
    }

    private func updateModel(with balance: BigInt) {
        self.keystore.store(object: wallet, fields: [.value(balance.description)])
        self.executing(false)
        self.finish(true)
    }
}
