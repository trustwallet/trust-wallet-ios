// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case kovan
    case ropsten
    case oraclesTest

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .ropsten: return 3
        case .oraclesTest: return 12648430
        }
    }

    var name: String {
        switch self {
        case .main: return "Ethereum"
        case .kovan: return "Kovan"
        case .ropsten: return "Ropsten"
        case .oraclesTest: return "Oracles"
        }
    }

    var isTestNetwork: Bool {
        switch self {
        case .main: return false
        case .kovan, .ropsten, .oraclesTest: return true
        }
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .kovan, .ropsten: return "ETH"
        case .oraclesTest: return "POA"
        }
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.kovan.name: return .kovan
            case RPCServer.ropsten.name: return .ropsten
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
            case RPCServer.ropsten.chainID: return .ropsten
            case RPCServer.oraclesTest.chainID: return .oraclesTest
            default: return .main
            }
        }()
    }
}
