// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct GetBalance: Web3Request {
    typealias Response = String
    let address: String
    var type: Web3RequestType {
        return .function(command: "web3.eth.getBalance('\(address)').toJSON")
    }
}
