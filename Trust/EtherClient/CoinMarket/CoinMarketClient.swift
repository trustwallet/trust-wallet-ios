// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum CoinMarketService {
    case price(id: String, currency: String)
    case prices(limit: Int)
}

extension CoinMarketService: TargetType {

    var baseURL: URL { return URL(string: "https://api.coinmarketcap.com/v1")! }

    var path: String {
        switch self {
        case .price(let id, _):
            return "/ticker/\(id)"
        case .prices:
            return "/ticker"
        }
    }

    var method: Moya.Method {
        switch self {
        case .price, .prices: return .get
        }
    }

    var task: Task {
        switch self {
        case .price(_, let currency):
            return .requestCompositeData(bodyData: Data(), urlParameters: ["convert": currency])
        case .prices(let limit):
            return .requestCompositeData(bodyData: Data(), urlParameters: ["limit": limit])
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
