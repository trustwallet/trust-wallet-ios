// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct ContractERC20Transfer: Web3Request {
    typealias Response = String

    let amount: BigInt
    let address: String

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall({\"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_value\", \"type\": \"uint256\" } ], \"name\": \"transfer\", \"outputs\": [ { \"name\": \"success\", \"type\": \"bool\" } ], \"type\": \"function\"} , [\"\(address)\", \"\(amount.description)\"])"
        return .script(command: run)
    }
}
