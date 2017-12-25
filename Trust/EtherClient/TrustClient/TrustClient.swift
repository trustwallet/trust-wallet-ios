// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case prices(currency: Currency, symbols: [String])
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
            return "/push/register"
        case .unregister:
            return "/push/unregister"
        case .prices:
            return "/prices"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTransactions: return .get
        case .getTransaction: return .get
        case .register: return .post
        case .unregister: return .delete
        case .prices: return .get
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
        case .prices(let currency, let symbols):
            return .requestParameters(
                parameters: [
                    "currency": currency.rawValue,
                    "symbols": symbols.joined(separator: ","),
                ],
                encoding:URLEncoding.queryString
            )
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
