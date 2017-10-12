// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit

protocol ExchangeRateCoordinatorDelegate: class {
    func didUpdate(rate: CurrencyRate, in coordinator: ExchangeRateCoordinator)
}

class ExchangeRateCoordinator: NSObject {

    weak var delegate: ExchangeRateCoordinatorDelegate?

    override init() {
        super.init()
        fetch()
    }

    func start() {
        fetch()
    }

    func fetch() {
        let request = GetRateRequest()
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.update(rate: response)
            case .failure(let error):
                self.update(error: error)
            }
        }
    }

    func update(rate: CurrencyRate) {
        delegate?.didUpdate(rate: rate, in: self)
    }

    func update(error: Error) {

    }
}

class GetRateRequest: Request {

    typealias Response = CurrencyRate

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/exchange-rates"
    }

    var parameters: Any? {
        return ["currency", "USD"]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard
            let dictionary = object as? [String: AnyObject],
            let data = dictionary["data"] as? [String: AnyObject],
            let currency = data["currency"] as? String,
            let rates = data["rates"] as? [String: String] else {
                 throw CastError(actualValue: object, expectedType: Response.self)
        }
        return CurrencyRate(
            currency: currency,
            rates: rates.map {
                Rate(
                    code: $0.key,
                    price: Double($0.value) ?? 0
                )
            }
        )
    }

    var baseURL: URL {
        return URL(string: "https://api.coinbase.com/v2")!
    }
}
