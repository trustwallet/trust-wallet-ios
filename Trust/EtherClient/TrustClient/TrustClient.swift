// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case getTransactions(address: String, startBlock: Int)
    case getTransaction(ID: String)
    case register(device: PushDevice)
    case unregister(device: PushDevice)
}

extension TrustService: TargetType {

    var baseURL: URL { return Config().remoteURL }

    var path: String {
        switch self {
        case .getTransactions:
            return "/transactions"
        case .getTransaction(let ID):
            return "/transactions/\(ID)"
        case .register:
            return "/register"
        case .unregister:
            return "/unregister"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTransactions: return .get
        case .getTransaction: return .get
        case .register: return .post
        case .unregister: return .delete
        }
    }

    var task: Task {
        switch self {
        case .getTransactions(let address, let startBlock):
            return .requestParameters(parameters: ["address": address, "startBlock": startBlock], encoding: URLEncoding())
        case .getTransaction:
            return .requestPlain
        case .register(let device):
            return .requestParameters(parameters: device.dict, encoding: JSONEncoding.default)
        case .unregister(let device):
            return .requestParameters(parameters: device.dict, encoding: JSONEncoding.default)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
