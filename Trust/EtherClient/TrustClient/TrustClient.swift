// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case transactions(address: String, startBlock: Int)
}

extension TrustService: TargetType {

    var baseURL: URL { return Config().remoteURL }

    var path: String {
        switch self {
        case .transactions:
            return "/transactions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .transactions: return .get
        }
    }

    var task: Task {
        switch self {
        case .transactions(let address, let startBlock):
            return .requestParameters(parameters: ["address": address, "startBlock": startBlock], encoding: URLEncoding())
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
