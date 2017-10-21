// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ContractERC20Transfer: Web3Request {
    typealias Response = String

    let amount: Double
    let decimals: Int64
    let address: String

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall({\"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_value\", \"type\": \"uint256\" } ], \"name\": \"transfer\", \"outputs\": [ { \"name\": \"success\", \"type\": \"bool\" } ], \"type\": \"function\"} , [\"\(address)\", Math.pow(10,\(decimals))*\(amount)])"
        return .script(command: run)
    }
}
