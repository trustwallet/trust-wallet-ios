// Copyright SIX DAY LLC. All rights reserved.

import TrustCore

class TokenBalanceOperation: TrustOperation {
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
        //DispatchQueue.main.async {
        //    self.store.update(balances: [self.address: balance.value])
        //}
        //print("\(balance) for \(self.address)")
        self.executing(false)
        self.finish(true)
    }
}
