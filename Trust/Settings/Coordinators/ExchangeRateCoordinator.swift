// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya
import RealmSwift

protocol ExchangeRateCoordinatorDelegate: class {
    func didUpdate(rate: CurrencyRate, in coordinator: ExchangeRateCoordinator)
}

class ExchangeRateCoordinator: NSObject {

    weak var delegate: ExchangeRateCoordinatorDelegate?

    private let provider = TrustProviderFactory.makeProvider()
    let config: Config

    init(
        config: Config
    ) {
        self.config = config
    }

    func start() {
        fetch()
    }

    func fetch() {
        let tokens = [TokenPrice(contract: "0x", symbol: config.server.symbol)]
        let tokensPrice = TokensPrice(
            currency: config.currency.rawValue,
            tokens: tokens
         )
        provider.request(.prices(tokensPrice)) { [weak self] result in
            guard let `self` = self else { return }
            guard case .success(let response) = result else { return }
            do {
                guard let ticker = try response.map([CoinTicker].self, atKeyPath: "response", using: JSONDecoder()).first else { return }
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
                    price: Double(ticker.price) ?? 0,
                    contract: ticker.contract
                ),
            ]
        )
        delegate?.didUpdate(rate: rate, in: self)
    }
}
