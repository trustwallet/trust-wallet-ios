// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case kovan

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        }
    }

    var name: String {
        switch self {
        case .main: return "Main"
        case .kovan: return "Kovan"
        }
    }

    init(name: String) {
        self = RPCServer(rawValue: name.lowercased()) ?? .main
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.kovan.chainID: return .kovan
            default: return .main
            }
        }()
    }
}
