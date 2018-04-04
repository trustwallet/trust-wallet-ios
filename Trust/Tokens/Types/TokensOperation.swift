// Copyright SIX DAY LLC. All rights reserved.

import TrustCore

class TokensOperation: TrustOperation {
    private var network: NetworkProtocol
    private let address: Address
    var tokens: [TokenObject] = [TokenObject]()

    init(
        network: NetworkProtocol,
        address: Address
    ) {
        self.network = network
        self.address = address
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        fetchTokensList()
    }

    private func fetchTokensList() {
        executing(true)
        network.tokensList(for: address) { result in
            guard let tokensList = result else {
                self.executing(false)
                self.finish(true)
                return
            }
            self.tokens.append(contentsOf: tokensList)
            self.executing(false)
            self.finish(true)
        }
    }
}
