// Copyright DApps Platform Inc. All rights reserved.

import TrustCore
import BigInt

final class TokenBalanceOperation: TrustOperation {
    private var balanceProvider: BalanceNetworkProvider
    private let store: TokensDataStore

    init(
        balanceProvider: BalanceNetworkProvider,
        store: TokensDataStore
    ) {
        self.balanceProvider = balanceProvider
        self.store = store
    }

    override func main() {
        updateBalance()
    }

    private func updateBalance() {
        balanceProvider.balance().done { [weak self] balance in
            guard let strongSelf = self else {
                self?.finish()
                return
            }
            strongSelf.updateModel(with: balance)
        }
    }

    private func updateModel(with balance: BigInt) {
        self.store.update(balance: balance, for: balanceProvider.addressUpdate)
        self.finish()
    }
}
