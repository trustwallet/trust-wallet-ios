// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustMarketService {
    case prices(currency: Currency, symbols: [String])
}

extension TrustMarketService: TargetType {

    var baseURL: URL { return URL(string: "https://api.trustwalletapp.com")! }

    var path: String {
        switch self {
        case .prices:
        return "/prices"
        }
    }

    var method: Moya.Method {
        switch self {
        case .prices: return .get
        }
    }

    var task: Task {
        switch self {
        case .prices(let currency, let symbols):
        return .requestParameters(parameters:["currency":currency.rawValue,"symbols":symbols.joined(separator: ",")],encoding:URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
