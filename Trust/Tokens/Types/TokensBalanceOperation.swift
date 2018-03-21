// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustKeystore
import BigInt

class TokensBalanceOperation: TrustOperation {
    private var network: NetworkProtocol
    private let addresses: [Address]
    var balances = [Address: BigInt]()
    private var pos = 0

    init(
        network: NetworkProtocol,
        addresses: [Address]
    ) {
        self.network = network
        self.addresses = addresses
    }

    override func main() {
        guard isCancelled == false, !addresses.isEmpty else {
            finish(true)
            return
        }
        executing(true)
        updateTokens()
    }

    private func updateTokens() {
        let address = addresses[pos]
        updateBalance(for: address) { [weak self] (balance) in
            guard let strongSelf = self else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            if balance != nil {
                strongSelf.balances[address] = balance
            }
            strongSelf.pos += 1
            if strongSelf.pos < strongSelf.addresses.count {
                strongSelf.updateTokens()
            } else {
                self?.executing(false)
                self?.finish(true)
            }
        }
    }

    private func updateBalance(for address: Address, completion: @escaping (BigInt?) -> Void) {
        network.tokenBalance(for: address) { result in
            completion(result?.value)
        }
    }
}
