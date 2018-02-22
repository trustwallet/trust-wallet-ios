// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum OpenseaService {
    case assets(address: String)
}

extension OpenseaService: TargetType {

    var baseURL: URL { return URL(string: "https://opensea-api.herokuapp.com")! }

    var path: String {
        switch self {
        case .assets:
            return "/assets"
        }
    }

    var method: Moya.Method {
        switch self {
        case .assets: return .get
        }
    }

    var task: Task {
        switch self {
        case .assets(let address):
            return .requestParameters(
                parameters: [
                    "owner": address,
                    "format": "json",
                    "order_by": "auction_created_date",
                    "order_direction": "desc",
                ], encoding: URLEncoding()
            )
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
