// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct ExchangeConfig {

    let server: RPCServer

    init(server: RPCServer) {
        self.server = server
    }

    var contract: Address? {
        switch server {
        case .main, .classic, .poa, .ropsten, .sokol:
            return nil
        case .kovan:
            return Address(string: "0x9044968086e365216cc9e441a8e2cea300dd7228")
        }
    }

    var tokenAddress: Address {
        switch server {
        case .main, .classic, .poa, .ropsten, .sokol:
            return Address(string: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
        case .kovan:
            return Address(string: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
        }
    }
}
