// Copyright DApps Platform Inc. All rights reserved.

import TrustCore

final class TokenBalanceOperation: TrustOperation {
    private var network: NetworkProtocol
    private let address: Address
    private let store: TokensDataStore

    init(
        network: NetworkProtocol,
        address: Address,
        store: TokensDataStore
        ) {
        self.network = network
        self.address = address
        self.store = store
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        updateBalance()
    }

    private func updateBalance() {
        executing(true)
        network.tokenBalance(for: address) { [weak self] result in
            guard let strongSelf = self, let balance = result else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            strongSelf.updateModel(with: balance)
        }
    }

    private func updateModel(with balance: Balance) {
        self.store.update(balance: balance.value, for: self.address)
        self.executing(false)
        self.finish(true)
    }
}
