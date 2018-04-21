// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import TrustCore

class TokensTickerOperation: TrustOperation {
    private var network: NetworkProtocol
    private let tokenPrices: [TokenPrice]
    var tickers: [CoinTicker] = [CoinTicker]()

    init(
        network: NetworkProtocol,
        tokenPrices: [TokenPrice]
        ) {
        self.network = network
        self.tokenPrices = tokenPrices
    }

    override func main() {
        guard isCancelled == false, !tokenPrices.isEmpty else {
            finish(true)
            return
        }
        fetchTickers()
    }

    private func fetchTickers() {
        executing(true)
        network.tickers(with: tokenPrices) {[weak self] result in
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
