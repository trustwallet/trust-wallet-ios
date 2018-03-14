// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustKeystore

class TokensBalanceOperation: TrustOperation {
    private var network: TokensNetworkProtocol
    private let address: Address
    var tokens: [TokenObject] = [TokenObject]()
    private var pos = 0

    init(
        network: TokensNetworkProtocol,
        address: Address
        ) {
        self.network = network
        self.address = address
    }

    override func main() {
        guard isCancelled == false, !tokens.isEmpty else {
            finish(true)
            return
        }
        executing(true)
        updateTokens()
    }

    private func updateTokens() {
        updateBalance(for: tokens[pos]) {[weak self] token in
            guard let strongSelf = self else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            let currentPos = strongSelf.pos
            strongSelf.tokens[currentPos] = token
            strongSelf.pos += 1
            if strongSelf.pos < strongSelf.tokens.count {
                strongSelf.updateTokens()
            } else {
                self?.executing(false)
                self?.finish(true)
            }
        }
    }

    private func updateBalance(for token: TokenObject, completion: @escaping ((TokenObject) -> Void)) {
        network.tokenBalance(for: token) { result in
            guard let balance = result.1 else {
                completion(token)
                return
            }
            let tempToken = token
            tempToken.value = balance.value.description
            completion(tempToken)
        }
    }
}
