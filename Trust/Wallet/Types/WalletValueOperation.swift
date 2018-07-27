// Copyright DApps Platform Inc. All rights reserved.

import UIKit

import TrustCore
import BigInt

final class WalletValueOperation: TrustOperation {
    private var balanceProvider: BalanceNetworkProvider
    private let store: WalletStorage

    init(
        balanceProvider: BalanceNetworkProvider,
        store: WalletStorage
        ) {
        self.balanceProvider = balanceProvider
        self.store = store
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
        balanceProvider.balance().done { [weak self] balance in
            guard let strongSelf = self else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            strongSelf.updateModel(with: balance)
        }
    }

    private func updateModel(with balance: BigInt) {
       // self.store.update(balance: balance, for: balanceProvider.addressUpdate)
        self.executing(false)
        self.finish(true)
    }
}
