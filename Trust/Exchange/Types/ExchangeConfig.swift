// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeConfig {

    let server: RPCServer

    init(server: RPCServer) {
        self.server = server
    }

    var contract: Address {
        switch server {
        case .main, .poa, .poaTest, .ropsten:
            return Address(address: "")
        case .kovan:
            return Address(address: "0x9044968086e365216cc9e441a8e2cea300dd7228")
        }
    }

    var tokenAddress: Address {
        switch server {
        case .main, .poa, .poaTest, .ropsten:
            return Address(address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
        case .kovan:
            return Address(address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
        }
    }
}
