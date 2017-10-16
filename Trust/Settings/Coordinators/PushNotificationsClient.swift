// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import Moya

enum PushNotificationsService {
    case register(device: PushDevice)
    case unregister(device: PushDevice)
}

extension PushNotificationsService: TargetType {

    var baseURL: URL { return Constants.pushNotificationsEndpoint }

    var path: String {
        switch self {
        case .register:
            return "/register"
        case .unregister:
            return "/unregister"
        }
    }

    var method: Moya.Method {
        switch self {
        case .register:
            return .post
        case .unregister:
            return .delete
        }
    }

    var task: Task {
        switch self {
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

class PushNotificationsClient {

    let provider = MoyaProvider<PushNotificationsService>()

    func register(device: PushDevice) {
        provider.request(.register(device: device)) { _ in }
    }

    func unregister(device: PushDevice) {
        provider.request(.unregister(device: device)) { _ in }
    }
}
