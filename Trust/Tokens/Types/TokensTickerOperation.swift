// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustKeystore

class TokensTickerOperation: TrustOperation {
    private var network: TokensNetworkProtocol
    private let address: Address
    var tokens: [TokenObject] = [TokenObject]()
    var tickers: [CoinTicker] = [CoinTicker]()

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
        fetchTickers()
    }

    private func fetchTickers() {
        executing(true)
        network.tickers(for: tokens) {[weak self] result in
            guard let tickers = result else {
                self?.executing(false)
                self?.finish(true)
                return
            }
            self?.tickers = tickers
            self?.executing(false)
            self?.finish(true)
        }
    }
}
