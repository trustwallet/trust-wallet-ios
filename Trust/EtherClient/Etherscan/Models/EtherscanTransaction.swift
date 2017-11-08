// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct EtherscanTransaction: Decodable {
    let blockNumber: String
    let timeStamp: String
    let hash: String
    let nonce: String
    let from: String
    let to: String
    let value: String
    let gas: String
    let gasPrice: String
    let input: String
    let contractAddress: String
    let cumulativeGasUsed: String
    let gasUsed: String
    let isError: String
}
