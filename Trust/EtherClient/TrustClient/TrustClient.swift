// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case prices(TokensPrice)
    case getTransactions(address: String, startBlock: Int)
    case getTransaction(ID: String)
    case register(device: PushDevice)
    case unregister(device: PushDevice)
}

struct TokensPrice: Encodable {
    let currency: String
    let tokens: [TokenPrice]
}

struct TokenPrice: Encodable {
    let contract: String
    let symbol: String
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
            return "/push/register"
        case .unregister:
            return "/push/unregister"
        case .prices:
            return "/tokenPrices"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTransactions: return .get
        case .getTransaction: return .get
        case .register: return .post
        case .unregister: return .delete
        case .prices: return .post
        }
    }

    var task: Task {
        switch self {
        case .getTransactions(let address, let startBlock):
            return .requestParameters(parameters: ["address": address, "startBlock": startBlock], encoding: URLEncoding())
        case .getTransaction:
            return .requestPlain
        case .register(let device):
            return .requestJSONEncodable(device)
        case .unregister(let device):
            return .requestJSONEncodable(device)
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
            "client-build" : Bundle.main.buildNumber ?? "",
        ]
    }
}
