// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeGetPrice: Web3Request {
    typealias Response = String

    static let abi = "{ \"constant\":true, \"inputs\":[ { \"name\":\"source\", \"type\":\"address\" }, { \"name\":\"dest\", \"type\":\"address\" } ], \"name\":\"getPrice\", \"outputs\":[ { \"name\":\"\", \"type\":\"uint256\" } ], \"payable\":false, \"stateMutability\":\"view\", \"type\":\"function\" }"

    let from: ExchangeToken
    let to: ExchangeToken

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall(\(ExchangeGetPrice.abi), [\"\(from.address.address)\", \"\(to.address.address)\"])"
        return .script(command: run)
    }
}

struct ExchangeGetPriceDecode: Web3Request {
    typealias Response = String

    let data: String

    var type: Web3RequestType {
        let run = "web3.eth.abi.decodeParameter('uint', '\(data)')"
        return .script(command: run)
    }
}
