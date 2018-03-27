// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustAPI {
    case dappsBootstrap
}

extension TrustAPI: TargetType {

    var baseURL: URL { return Config().server.apiURL }

    var path: String {
        switch self {
        case .dappsBootstrap:
            return "/dapps/bootstrap"
        }
    }

    var method: Moya.Method {
        switch self {
        case .dappsBootstrap: return .get
        }
    }

    var task: Task {
        switch self {
        case .dappsBootstrap:
            return .requestParameters(parameters: [:], encoding: URLEncoding())
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
