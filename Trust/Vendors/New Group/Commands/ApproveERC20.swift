// Copyright SIX DAY LLC. All rights reserved.

import Foundation


struct ApproveERC20Encode: Web3Request {
    typealias Response = String

    static let abi = "{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_amount\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"

    let address: Address
    let amount: String

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall(\(ApproveERC20Encode.abi), [\"\(address.address)\", \"\(amount)\"])"
        return .script(command: run)
    }
}
