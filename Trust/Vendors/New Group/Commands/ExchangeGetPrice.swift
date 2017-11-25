// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeGetPrice: Web3Request {
    typealias Response = String

    let from: Address
    let to: Address

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall({ \"constant\":true, \"inputs\":[ { \"name\":\"source\", \"type\":\"address\" }, { \"name\":\"dest\", \"type\":\"address\" } ], \"name\":\"getPrice\", \"outputs\":[ { \"name\":\"\", \"type\":\"uint256\" } ], \"payable\":false, \"stateMutability\":\"view\", \"type\":\"function\" }, [\"\(from.address)\", \"\(to.address)\"])"
        return .script(command: run)
    }
}
