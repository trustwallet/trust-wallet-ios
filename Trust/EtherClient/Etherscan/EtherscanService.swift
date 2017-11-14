// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum EtherscanService {
    case transactions(address: String, startBlock: Int, endBlock: Int)
}

extension EtherscanService: TargetType {

    var baseURL: URL { return Config().etherScanAPIURL }

    var path: String {
        switch self {
        case .transactions:
            return "/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .transactions: return .get
        }
    }

    var task: Task {
        switch self {
        case .transactions(let address, let startBlock, let endBlock):
            return .requestParameters(parameters: [
            "module": "account",
            "action": "txlist",
            "address": address,
            "startblock": startBlock,
            "endblock": endBlock,
            "sort": "asc",
            "apikey": "7V8AMAVQWKNAZHZG8ARYB9SQWWKBBDA7S8",
        ], encoding: URLEncoding())
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
