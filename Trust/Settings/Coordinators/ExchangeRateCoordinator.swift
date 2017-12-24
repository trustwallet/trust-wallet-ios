// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya
import RealmSwift

protocol ExchangeRateCoordinatorDelegate: class {
    func didUpdate(rate: CurrencyRate, in coordinator: ExchangeRateCoordinator)
}

class ExchangeRateCoordinator: NSObject {

    weak var delegate: ExchangeRateCoordinatorDelegate?

    private let provider = MoyaProvider<TrustMarketService>()
    
    func start() {
        fetch()
    }
    
    func fetch() {
        provider.request(.prices(currency: Config().currency, symbols:["ETH"])) { (result) in
            guard  case .success(let response) = result else { return }
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
                    price: Double(ticker.price) ?? 0
                ),
            ]
        )
        delegate?.didUpdate(rate: rate, in: self)
    }
}
