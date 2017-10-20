// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum CoinMarketService {
    case price(id: String, currency: String)
}

extension CoinMarketService: TargetType {

    var baseURL: URL { return URL(string: "https://api.coinmarketcap.com/v1")! }

    var path: String {
        switch self {
        case .price(let id, _):
            return "/ticker/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .price: return .get
        }
    }

    var task: Task {
        switch self {
        case .price(_, let currency):
            return .requestCompositeData(bodyData: Data(), urlParameters: ["convert": currency])
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
