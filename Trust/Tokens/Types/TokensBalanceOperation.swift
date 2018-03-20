// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustKeystore
import BigInt

class TokensBalanceOperation: TrustOperation {
    private var network: NetworkProtocol
    private let address: Address
    private let fetchTokens: [TokenObject]
    var tokens = [TokenObject: BigInt]()
    private var pos = 0

    init(
        network: NetworkProtocol,
        address: Address,
        fetchTokens: [TokenObject]
    ) {
        self.network = network
        self.address = address
        self.fetchTokens = fetchTokens
    }

    override func main() {
        guard isCancelled == false, !fetchTokens.isEmpty else {
            finish(true)
            return
        }
        executing(true)
        updateTokens()
    }

    private func updateTokens() {
        updateBalance(for: fetchTokens[pos]) { [weak self] (token, balance) in
            guard let strongSelf = self else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            if balance != nil {
                strongSelf.tokens[token] = balance
            }
            strongSelf.pos += 1
            if strongSelf.pos < strongSelf.fetchTokens.count {
                strongSelf.updateTokens()
            } else {
                self?.executing(false)
                self?.finish(true)
            }
        }
    }

    private func updateBalance(for token: TokenObject, completion: @escaping ((TokenObject, BigInt?) -> Void)) {
        network.tokenBalance(for: token) { result in
            guard let balance = result.1 else {
                completion(token, .none)
                return
            }
            completion(token, balance.value)
        }
    }
}
