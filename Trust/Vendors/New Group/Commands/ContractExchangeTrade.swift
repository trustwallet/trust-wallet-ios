// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct ContractExchangeTrade: Web3Request {
    typealias Response = String

    let source: String
    let value: BigInt
    let dest: String
    let destAddress: String
    let maxDestAmount: String
    let minConversionRate: Int
    let throwOnFailure: Bool
    let walletId: String

    static var abi: String = "{\"constant\":false,\"inputs\":[{\"name\":\"source\",\"type\":\"address\"},{\"name\":\"srcAmount\",\"type\":\"uint256\"},{\"name\":\"dest\",\"type\":\"address\"},{\"name\":\"destAddress\",\"type\":\"address\"},{\"name\":\"maxDestAmount\",\"type\":\"uint256\"},{\"name\":\"minConversionRate\",\"type\":\"uint256\"},{\"name\":\"throwOnFailure\",\"type\":\"bool\"}, {\"name\":\"walletId\",\"type\":\"bytes32\"}, ],\"name\":\"walletTrade\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}"

    var type: Web3RequestType {
        let run = "web3.eth.abi.encodeFunctionCall(\(ContractExchangeTrade.abi), [\"\(source)\", \"\(value.description)\", \"\(dest)\", \"\(destAddress)\", \"\(maxDestAmount)\", \"\(minConversionRate)\", \"\(throwOnFailure)\", \"\(walletId)\"])"
        return .script(command: run)
    }
}

