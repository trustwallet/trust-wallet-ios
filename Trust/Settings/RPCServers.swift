// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case ropsten
    case kovan
    case rinkeby

    var chainID: Int {
        switch self {
        case .main: return 1
        case .ropsten: return 3
        case .kovan: return 42
        case .rinkeby: return 4
        }
    }

    var name: String {
        switch self {
        case .main: return "Main"
        case .ropsten: return "Ropsten"
        case .kovan: return "Kovan"
        case .rinkeby: return "Rinkeby"
        }
    }

    init(name: String) {
        self = RPCServer(rawValue: name.lowercased()) ?? .main
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.ropsten.chainID: return .ropsten
            case RPCServer.kovan.chainID: return .kovan
            case RPCServer.rinkeby.chainID: return .rinkeby
            default: return .main
            }
        }()
    }
}
