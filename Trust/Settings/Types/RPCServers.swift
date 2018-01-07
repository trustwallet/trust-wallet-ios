// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case kovan
    case ropsten
    case poa
    case classic

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .ropsten: return 3
        case .poa: return 99
        case .classic: return 61
        }
    }

    var name: String {
        switch self {
        case .main: return "Ethereum"
        case .kovan: return "Kovan"
        case .ropsten: return "Ropsten"
        case .poa: return "POA Network"
        case .classic: return "Ethereum Classic"
        }
    }

    var isTestNetwork: Bool {
        switch self {
        case .main, .poa, .classic: return false
        case .kovan, .ropsten: return true
        }
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .classic: return "ETC"
        case .kovan, .ropsten: return "ETH"
        case .poa: return "POA"
        }
    }

    var decimals: Int {
        return 18
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.classic.name: return .classic
            case RPCServer.kovan.name: return .kovan
            case RPCServer.ropsten.name: return .ropsten
            case RPCServer.poa.name: return .poa
            default: return .main
            }
        }()
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.classic.chainID: return .classic
            case RPCServer.kovan.chainID: return .kovan
            case RPCServer.ropsten.chainID: return .ropsten
            case RPCServer.poa.chainID: return .poa
            default: return .main
            }
        }()
    }
}
