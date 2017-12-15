// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum RPCServer: String {
    case main
    case kovan
    case ropsten
    case poa
    case poaTest

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .ropsten: return 3
        case .poa: return 99
        case .poaTest: return 12648430
        }
    }

    var name: String {
        switch self {
        case .main: return "Ethereum"
        case .kovan: return "Kovan"
        case .ropsten: return "Ropsten"
        case .poa, .poaTest: return "POA Network"
        }
    }

    var isTestNetwork: Bool {
        switch self {
        case .main, .poa: return false
        case .kovan, .ropsten, .poaTest: return true
        }
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .kovan, .ropsten: return "ETH"
        case .poa, .poaTest: return "POA"
        }
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.kovan.name: return .kovan
            case RPCServer.ropsten.name: return .ropsten
            case RPCServer.poa.name: return .poa
            case RPCServer.poaTest.name: return .poaTest
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
            case RPCServer.poa.chainID: return .poa
            case RPCServer.poaTest.chainID: return .poaTest
            default: return .main
            }
        }()
    }
}
