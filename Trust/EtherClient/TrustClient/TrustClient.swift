// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case getTransactions(address: String, startBlock: Int)
    case getTransaction(ID: String)
}

extension TrustService: TargetType {

    var baseURL: URL { return Config().remoteURL }

    var path: String {
        switch self {
        case .getTransactions:
            return "/transactions"
        case .getTransaction(let ID):
            return "/transactions/\(ID)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTransactions: return .get
        case .getTransaction: return .get
        }
    }

    var task: Task {
        switch self {
        case .getTransactions(let address, let startBlock):
            return .requestParameters(parameters: ["address": address, "startBlock": startBlock], encoding: URLEncoding())
        case .getTransaction:
            return .requestPlain
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
