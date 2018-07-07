// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case getTransactions(address: String, startBlock: Int, page: Int, contract: String?)
    case getTokens(address: String, showBalance: Bool)
    case getTransaction(ID: String)
    case register(device: PushDevice)
    case unregister(device: PushDevice)
    case assets(address: String)
    case search(token: String)
}

extension TrustService: TargetType {

    var baseURL: URL { return Config().server.remoteURL }

    var path: String {
        switch self {
        case .getTransactions:
            return "/transactions"
        case .getTokens:
            return "/tokens"
        case .getTransaction(let ID):
            return "/transactions/\(ID)"
        case .register:
            return "/push/register"
        case .unregister:
            return "/push/unregister"
        case .assets:
            return "/assets"
        case .search:
            return "/tokens/list"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTransactions: return .get
        case .getTokens: return .get
        case .getTransaction: return .get
        case .register: return .post
        case .unregister: return .post
        case .assets: return .get
        case .search: return .get
        }
    }

    var task: Task {
        switch self {
        case .getTransactions(let address, let startBlock, let page, let contract):
            var params: [String: Any] = ["address": address, "startBlock": startBlock, "page": page]
            if let transactionContract = contract {
                params["contract"] = transactionContract
            }
            return .requestParameters(parameters: params, encoding: URLEncoding())
        case .getTokens(let address, let showBalance):
            return .requestParameters(parameters: [
                "address": address,
                "showBalance": showBalance,
            ], encoding: URLEncoding())
        case .getTransaction:
            return .requestPlain
        case .register(let device):
            return .requestJSONEncodable(device)
        case .unregister(let device):
            return .requestJSONEncodable(device)
        case .assets(let address):
            return .requestParameters(parameters: ["address": address], encoding: URLEncoding())
        case .search(let token):
            return .requestParameters(parameters: ["query": token], encoding: URLEncoding())
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
