// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct GetERC20BalanceEncode: Web3Request {
    typealias Response = String

    static let abi = "{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"

    let address: Address

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall(\(GetERC20BalanceEncode.abi), [\"\(address.address)\"])"
        return .script(command: run)
    }
}

struct GetERC20BalanceDecode: Web3Request {
    typealias Response = String

    let data: String

    var type: Web3RequestType {
        let run = "web3.eth.abi.decodeParameter('uint', '\(data)')"
        return .script(command: run)
    }
}
