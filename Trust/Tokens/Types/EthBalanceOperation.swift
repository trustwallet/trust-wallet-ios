// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import BigInt

class EthBalanceOperation: TrustOperation {
    private var network: NetworkProtocol
    var balance: Balance = Balance(value: BigInt(0))

    init(network: NetworkProtocol) {
        self.network = network
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        fetchBalance()
    }

    private func fetchBalance() {
        executing(true)
        network.ethBalance { [weak self] result in
            self?.balance = result ?? Balance(value: BigInt(0))
            self?.executing(false)
            self?.finish(true)
        }
    }
}
