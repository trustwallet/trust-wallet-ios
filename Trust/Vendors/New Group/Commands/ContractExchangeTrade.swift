// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ContractExchangeTrade: Web3Request {
    typealias Response = String

    let source: String
    let amount: String
    let dest: String
    let destAddress: String
    let maxDestAmount: String
    let minConversionRate: Int
    let throwOnFailure: Bool
    let walletId: String

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall({\"constant\":false,\"inputs\":[{\"name\":\"source\",\"type\":\"address\"},{\"name\":\"srcAmount\",\"type\":\"uint256\"},{\"name\":\"dest\",\"type\":\"address\"},{\"name\":\"destAddress\",\"type\":\"address\"},{\"name\":\"maxDestAmount\",\"type\":\"uint256\"},{\"name\":\"minConversionRate\",\"type\":\"uint256\"},{\"name\":\"throwOnFailure\",\"type\":\"bool\"}],\"name\":\"trade\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}, [\"\(source)\", \"\(amount)\", \"\(dest)\", \"\(destAddress)\", \"\(maxDestAmount)\", \"\(minConversionRate)\", \"\(throwOnFailure)\"])"
        return .script(command: run)
    }
}

