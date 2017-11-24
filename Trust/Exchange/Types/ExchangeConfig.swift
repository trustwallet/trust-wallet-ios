// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeConfig {

    let server: RPCServer

    init(server: RPCServer) {
        self.server = server
    }

    var contract: Address {
        switch server {
        case .main, .oraclesTest:
            return Address(address: "")
        case .kovan:
            return Address(address: "0x11542d7807dfb2b44937f756b9092c76e814f8ed")
        }
    }
}
