// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustAPI {
    case prices(TokensPrice)
}

struct TokensPrice: Encodable {
    let currency: String
    let tokens: [TokenPrice]
}

struct TokenPrice: Encodable {
    let contract: String
    let symbol: String
}

extension TrustAPI: TargetType {

    var baseURL: URL { return Constants.trustAPI }

    var path: String {
        switch self {
        case .prices:
            return "/tokenPrices"
        }
    }

    var method: Moya.Method {
        switch self {
        case .prices: return .post
        }
    }

    var task: Task {
        switch self {
        case .prices(let tokensPrice):
            return .requestJSONEncodable(tokensPrice)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return [
            "Content-type": "application/json",
            "client": Bundle.main.bundleIdentifier ?? "",
            "client-build": Bundle.main.buildNumber ?? "",
        ]
    }
}
