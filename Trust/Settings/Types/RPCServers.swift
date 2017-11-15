// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case kovan
    case oraclesTest

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .oraclesTest: return 12648430
        }
    }

    var name: String {
        switch self {
        case .main: return "Main"
        case .kovan: return "Kovan"
        case .oraclesTest: return "Oracles (Test network)"
        }
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .kovan: return "ETH"
        case .oraclesTest: return "POA"
        }
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.kovan.name: return .kovan
            case RPCServer.oraclesTest.name: return .oraclesTest
            default: return .main
            }
        }()
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.kovan.chainID: return .kovan
            case RPCServer.oraclesTest.chainID: return .oraclesTest
            default: return .main
            }
        }()
    }
}
