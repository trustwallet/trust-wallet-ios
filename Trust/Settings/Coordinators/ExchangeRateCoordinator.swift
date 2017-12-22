// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

protocol ExchangeRateCoordinatorDelegate: class {
    func didUpdate(rate: CurrencyRate, in coordinator: ExchangeRateCoordinator)
}

class ExchangeRateCoordinator: NSObject {

    weak var delegate: ExchangeRateCoordinatorDelegate?

    private let provider = MoyaProvider<CoinMarketService>()

    func start() {
        fetch()
    }

    func fetch() {
        provider.request(.price(id: CoinTickerID.ETH.ID, currency: "USD")) { result in
            guard  case .success(let response) = result else { return }
            do {
                guard let ticker = try response.map([CoinTicker].self).first else { return }
                self.update(ticker: ticker)
            } catch { }
        }
    }

    func update(ticker: CoinTicker) {
        let rate = CurrencyRate(
            currency: ticker.symbol,
            rates: [
                Rate(
                    code: ticker.symbol,
                    price: Double(ticker.usdPrice) ?? 0
                ),
            ]
        )
        delegate?.didUpdate(rate: rate, in: self)
    }
}
